import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';

import '../models/asistencia_model.dart';
import '../models/estadisticas_model.dart';
import '../models/ficha_model.dart';
import '../services/api_service.dart';

class AsistenciaProvider with ChangeNotifier {
  final ApiService _apiService;
  
  // Estado de carga
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Datos
  Map<String, EstadisticasJornada> _estadisticas = {};
  List<Asistencia> _asistencias = [];
  List<FichaModel> _fichas = [];
  String _jornadaActual = '';
  Timer? _refreshTimer;
  
  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  Map<String, EstadisticasJornada> get estadisticas => _estadisticas;
  List<Asistencia> get asistencias => _asistencias;
  List<FichaModel> get fichas => _fichas;
  String get jornadaActual => _jornadaActual;
  ApiService get apiService => _apiService;

  /// Devuelve las fichas de la jornada actual
  List<FichaModel> get fichasJornadaActual {
    if (_jornadaActual.isEmpty) return [];
    return _fichas.where((f) => _normalizar(f.jornadaFormacion.jornada) == _normalizar(_jornadaActual)).toList();
  }

  /// Devuelve las asistencias de las fichas de la jornada actual
  List<Asistencia> get asistenciasJornadaActual {
    final fichasIds = fichasJornadaActual.map((f) => f.numeroFicha.toString()).toSet();
    final jornadaActualNorm = _normalizar(_jornadaActual);
    return _asistencias.where((a) => fichasIds.contains(a.ficha) && _normalizar(a.jornada) == jornadaActualNorm).toList();
  }
  
  /// Constructor
  AsistenciaProvider({required ApiService apiService}) : _apiService = apiService {
    _init();
  }
  
  /// Inicialización del provider
  Future<void> _init() async {
    await cargarDatos();
    _configurarActualizacionAutomatica();
  }
  
  /// Carga todos los datos iniciales
  Future<void> cargarDatos() async {
    _setLoading(true);
    _clearError();
    try {
      _jornadaActual = JornadaConstants.getJornadaString(JornadaConstants.getJornadaActual());
      await _cargarEstadisticas();
      await _cargarFichas();
      await _cargarAsistencias();
    } catch (e) {
      _setError('Error general al cargar los datos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Configura la actualización automática periódica
  void _configurarActualizacionAutomatica() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: ApiConstants.refreshTime),
      (timer) => _actualizarDatos(),
    );
  }
  
  /// Actualiza los datos principales
  Future<void> _actualizarDatos() async {
    try {
      final nuevaJornada = JornadaConstants.getJornadaActual();
      if (JornadaConstants.getJornadaString(nuevaJornada) != _jornadaActual) {
        _jornadaActual = JornadaConstants.getJornadaString(nuevaJornada);
      }
      await _cargarEstadisticas();
      await _cargarFichas();
      await _cargarAsistencias();
      notifyListeners();
    } catch (e) {
      debugPrint('Error al actualizar datos: $e');
    }
  }

  /// Carga estadísticas desde el API
  Future<void> _cargarEstadisticas() async {
    try {
      _estadisticas = await _apiService.getEstadisticas();
    } catch (e) {
      _setError('Error al cargar estadísticas: $e');
      _estadisticas = {};
    }
  }

  /// Carga fichas desde el API
  Future<void> _cargarFichas() async {
    try {
      _fichas = await _apiService.getFichas();
    } catch (e) {
      _setError('Error al cargar fichas: $e');
      _fichas = [];
    }
  }

  /// Carga asistencias de la jornada actual desde el API
  Future<void> _cargarAsistencias() async {
    if (_jornadaActual.isEmpty) {
      _asistencias = [];
      return;
    }
    try {
      _asistencias = await _apiService.getAsistenciasPorJornada(int.parse(_jornadaActual));
    } catch (e) {
      _setError('Error al cargar asistencias: $e');
      _asistencias = [];
    }
  }

  /// Devuelve las estadísticas de una jornada específica
  EstadisticasJornada? getEstadisticasJornada(String jornada) {
    return _estadisticas[jornada];
  }
  
  /// Devuelve las asistencias filtradas por programa
  List<Asistencia> getAsistenciasPorPrograma(String programa) {
    return _asistencias.where((a) => a.programa == programa).toList();
  }
  
  /// Acceso estático al provider
  static AsistenciaProvider of(context, {bool listen = true}) {
    return Provider.of<AsistenciaProvider>(context, listen: listen);
  }

  // --- Métodos privados auxiliares ---

  String _normalizar(String s) {
    return s.trim().toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage += message + '\n';
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }
}
