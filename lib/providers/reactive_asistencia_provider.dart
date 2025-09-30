import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../models/asistencia_detalle_model.dart';
import '../services/reactive_asistencias_service.dart';
import '../services/api_service.dart';

/// Provider reactivo que maneja las asistencias con actualizaciones granulares
/// Solo actualiza los widgets que han cambiado
class ReactiveAsistenciaProvider with ChangeNotifier {
  final ApiService _apiService;
  final ReactiveAsistenciasService _reactiveService;

  // Estado de carga
  bool _isLoading = false;
  bool _isUpdating = false;
  String _errorMessage = '';

  // Datos
  List<AsistenciaDetalle> _asistenciasIniciales = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  List<AsistenciaDetalle> get asistenciasIniciales => _asistenciasIniciales;
  ReactiveAsistenciasService get reactiveService => _reactiveService;

  /// Constructor
  ReactiveAsistenciaProvider({
    required ApiService apiService,
  })  : _apiService = apiService,
        _reactiveService = ReactiveAsistenciasService() {
    _init();
  }

  /// Inicialización del provider
  Future<void> _init() async {
    await cargarDatosIniciales();
  }

  /// Carga los datos iniciales desde el API
  Future<void> cargarDatosIniciales() async {
    _setLoading(true);
    _clearError();

    try {
      // Obtener asistencias del día actual
      final response = await _apiService.getAsistenciasPorJornada(
        jornadaId: null,
        fecha: DateTime.now(),
      );

      _asistenciasIniciales = response.asistencias;

      // Inicializar el servicio reactivo
      await _reactiveService.initialize(_asistenciasIniciales);

      debugPrint(
          '✅ ReactiveAsistenciaProvider inicializado con ${_asistenciasIniciales.length} asistencias');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al cargar datos iniciales: $e');
      _setError('Error al cargar datos iniciales: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza manualmente los datos desde el API
  Future<void> refrescarDatos() async {
    _setUpdating(true);
    _clearError();

    try {
      final response = await _apiService.getAsistenciasPorJornada(
        jornadaId: null,
        fecha: DateTime.now(),
      );

      _asistenciasIniciales = response.asistencias;

      // Actualizar el servicio reactivo
      _reactiveService.actualizarDatos(_asistenciasIniciales);

      debugPrint(
          '✅ Datos refrescados: ${_asistenciasIniciales.length} asistencias');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al refrescar datos: $e');
      _setError('Error al refrescar datos: $e');
    } finally {
      _setUpdating(false);
    }
  }

  /// Obtiene las asistencias de una jornada específica
  List<AsistenciaDetalle> getAsistenciasJornada(String jornada) {
    return _reactiveService.getAsistenciasJornada(jornada);
  }

  /// Obtiene las jornadas disponibles
  List<String> get jornadasDisponibles => _reactiveService.jornadasDisponibles;

  /// Obtiene estadísticas generales
  Map<String, int> get estadisticas {
    final asistencias = _reactiveService.todasLasAsistencias;
    final enCurso = asistencias.where((a) => a.isEnCurso).length;
    final completas = asistencias.where((a) => a.isCompleta).length;

    return {
      'total': asistencias.length,
      'en_curso': enCurso,
      'completas': completas,
    };
  }

  /// Acceso estático al provider
  static ReactiveAsistenciaProvider of(context, {bool listen = true}) {
    return Provider.of<ReactiveAsistenciaProvider>(context, listen: listen);
  }

  // --- Métodos privados auxiliares ---

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setUpdating(bool value) {
    _isUpdating = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }

  /// Limpia los recursos al destruir el provider
  @override
  void dispose() {
    _reactiveService.dispose();
    super.dispose();
  }
}
