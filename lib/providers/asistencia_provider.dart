import 'dart:async';
import 'dart:convert';
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

  /// Fichas de la jornada actual
  List<FichaModel> get fichasJornadaActual {
    if (_jornadaActual.isEmpty) return [];
    String normalizar(String s) => s.trim().toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');
    return _fichas.where((f) =>
      normalizar(f.jornadaFormacion.jornada) == normalizar(_jornadaActual)
    ).toList();
  }

  /// Asistencias de fichas de la jornada actual
  List<Asistencia> get asistenciasJornadaActual {
    final fichasIds = fichasJornadaActual.map((f) => f.numeroFicha.toString()).toSet();
    String jornadaActualNormalizada = _jornadaActual.trim().toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
    return _asistencias.where((a) {
      String jornadaAsistenciaNormalizada = a.jornada.trim().toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
      // Debug print para ver los valores comparados
      // ignore: avoid_print
      print('Comparando asistencia: ficha=${a.ficha}, jornadaAsistencia=$jornadaAsistenciaNormalizada vs jornadaActual=$jornadaActualNormalizada');
      return fichasIds.contains(a.ficha) && jornadaAsistenciaNormalizada == jornadaActualNormalizada;
    }).toList();
  }
  
  // Constructor
  AsistenciaProvider({required ApiService apiService}) : _apiService = apiService {
    _init();
    // _initWebSocket(); // Desactivado porque el servicio fue eliminado
  }
  
  // Inicialización
  Future<void> _init() async {
    await cargarDatos();
    _configurarActualizacionAutomatica();
  }
  
  // Cargar datos iniciales
  Future<void> cargarDatos() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Actualizar la jornada actual
      _jornadaActual = JornadaConstants.getJornadaString(JornadaConstants.getJornadaActual());

      // Cargar estadísticas (no detener si falla)
      try {
        _estadisticas = await _apiService.getEstadisticas();
      } catch (e) {
        _errorMessage += 'Error al cargar estadísticas: $e\n';
        _estadisticas = {};
      }

      // Cargar fichas (siempre intentar)
      try {
        _fichas = await _apiService.getFichas();
      } catch (e) {
        _errorMessage += 'Error al cargar fichas: $e\n';
        _fichas = [];
      }

      // Si hay una jornada activa, cargar sus asistencias
      if (_jornadaActual.isNotEmpty) {
        try {
          _asistencias = await _apiService.getAsistenciasPorJornada(_jornadaActual);
        } catch (e) {
          _errorMessage += 'Error al cargar asistencias: $e\n';
          _asistencias = [];
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage += 'Error general al cargar los datos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Configurar actualización automática
  void _configurarActualizacionAutomatica() {
    // Cancelar el temporizador existente si lo hay
    _refreshTimer?.cancel();
    
    // Configurar un nuevo temporizador
    _refreshTimer = Timer.periodic(
      const Duration(seconds: ApiConstants.refreshTime),
      (timer) => _actualizarDatos(),
    );
  }
  
  // Actualizar datos
  Future<void> _actualizarDatos() async {
    try {
      // Verificar si la jornada ha cambiado
      final nuevaJornada = JornadaConstants.getJornadaActual();
      final jornadaCambio = nuevaJornada != _jornadaActual;
      
      if (jornadaCambio) {
        _jornadaActual = JornadaConstants.getJornadaString(nuevaJornada);
      }
      
      // Actualizar estadísticas
      _estadisticas = await _apiService.getEstadisticas();
      
      // Cargar fichas
      _fichas = await _apiService.getFichas();

      // Si hay una jornada activa, actualizar sus asistencias
      if (_jornadaActual.isNotEmpty) {
        _asistencias = await _apiService.getAsistenciasPorJornada(_jornadaActual);
      } else {
        _asistencias = [];
      }
      
      notifyListeners();
    } catch (e) {
      // No actualizamos el estado de error para no interrumpir la vista actual
      debugPrint('Error al actualizar datos: $e');
    }
  }
  
  // Obtener estadísticas de una jornada específica
  EstadisticasJornada? getEstadisticasJornada(String jornada) {
    return _estadisticas[jornada];
  }
  
  // Obtener asistencias filtradas por programa
  List<Asistencia> getAsistenciasPorPrograma(String programa) {
    return _asistencias.where((a) => a.programa == programa).toList();
  }
  
  // Método estático para facilitar el acceso al provider
  static AsistenciaProvider of(context, {bool listen = true}) {
    return Provider.of<AsistenciaProvider>(context, listen: listen);
  }
}
