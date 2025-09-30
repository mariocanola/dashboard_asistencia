import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/asistencia_detalle_model.dart';
import '../models/websocket_event.dart';
import '../providers/asistencia_provider.dart';
import '../services/websocket_pusher_service.dart';

/// Servicio que combina datos del API con eventos WebSocket para proporcionar
/// un stream continuo de asistencias en tiempo real
class AsistenciasStreamService {
  static final AsistenciasStreamService _instance =
      AsistenciasStreamService._internal();
  factory AsistenciasStreamService() => _instance;
  AsistenciasStreamService._internal();

  final WebSocketPusherService _webSocketService = WebSocketPusherService();
  final StreamController<List<AsistenciaDetalle>> _asistenciasController =
      StreamController<List<AsistenciaDetalle>>.broadcast();

  // Estado interno
  List<AsistenciaDetalle> _asistenciasActuales = [];
  StreamSubscription<WebSocketEvent>? _webSocketSubscription;
  bool _isInitialized = false;

  /// Stream de asistencias en tiempo real
  Stream<List<AsistenciaDetalle>> get asistenciasStream =>
      _asistenciasController.stream;

  /// Estado de conexión WebSocket
  Stream<String> get connectionStateStream =>
      _webSocketService.connectionStateStream;

  /// Inicializa el servicio
  Future<void> initialize(AsistenciaProvider provider) async {
    if (_isInitialized) return;

    // Cargar datos iniciales
    await _loadInitialData(provider);

    // Configurar listener de WebSocket
    _setupWebSocketListener(provider);

    _isInitialized = true;
    debugPrint('✅ AsistenciasStreamService inicializado');
  }

  /// Carga los datos iniciales desde el provider
  Future<void> _loadInitialData(AsistenciaProvider provider) async {
    try {
      // Obtener datos actuales del provider
      _asistenciasActuales = List.from(provider.asistenciasDetalle);

      // Emitir datos iniciales
      _asistenciasController.add(_asistenciasActuales);

      debugPrint(
        '📊 Datos iniciales cargados: ${_asistenciasActuales.length} asistencias',
      );
    } catch (e) {
      debugPrint('❌ Error al cargar datos iniciales: $e');
      _asistenciasController.add([]);
    }
  }

  /// Configura el listener de eventos WebSocket
  void _setupWebSocketListener(AsistenciaProvider provider) {
    _webSocketSubscription?.cancel();

    _webSocketSubscription = _webSocketService.eventStream.listen(
      (event) => _handleWebSocketEvent(event, provider),
      onError: (error) {
        debugPrint('❌ Error en stream de eventos WebSocket: $error');
      },
    );
  }

  /// Maneja eventos recibidos del WebSocket
  Future<void> _handleWebSocketEvent(
    WebSocketEvent event,
    AsistenciaProvider provider,
  ) async {
    if (!event.isNuevaAsistencia) return;

    debugPrint(
      '🔄 Procesando nueva asistencia desde WebSocket: ${event.aprendizNombre}',
    );

    try {
      // Actualizar datos desde el API para obtener información completa
      await provider.cargarAsistencias();

      // Obtener datos actualizados
      _asistenciasActuales = List.from(provider.asistenciasDetalle);

      // Emitir datos actualizados
      _asistenciasController.add(_asistenciasActuales);

      debugPrint(
        '✅ Asistencias actualizadas: ${_asistenciasActuales.length} total',
      );
    } catch (e) {
      debugPrint('❌ Error al actualizar asistencias desde WebSocket: $e');
    }
  }

  /// Actualiza manualmente los datos desde el provider
  Future<void> refreshFromProvider(AsistenciaProvider provider) async {
    try {
      await provider.cargarAsistencias();
      _asistenciasActuales = List.from(provider.asistenciasDetalle);
      _asistenciasController.add(_asistenciasActuales);
    } catch (e) {
      debugPrint('❌ Error al refrescar desde provider: $e');
    }
  }

  /// Obtiene las asistencias agrupadas por jornada
  Map<String, List<AsistenciaDetalle>> get asistenciasPorJornada {
    final Map<String, List<AsistenciaDetalle>> porJornada = {};

    for (var asistencia in _asistenciasActuales) {
      if (!porJornada.containsKey(asistencia.jornada)) {
        porJornada[asistencia.jornada] = [];
      }
      porJornada[asistencia.jornada]!.add(asistencia);
    }

    return porJornada;
  }

  /// Obtiene estadísticas de las asistencias actuales
  Map<String, int> get estadisticas {
    final enCurso = _asistenciasActuales.where((a) => a.isEnCurso).length;
    final completas = _asistenciasActuales.where((a) => a.isCompleta).length;

    return {
      'total': _asistenciasActuales.length,
      'en_curso': enCurso,
      'completas': completas,
    };
  }

  /// Libera los recursos del servicio
  void dispose() {
    _webSocketSubscription?.cancel();
    _asistenciasController.close();
    _isInitialized = false;
  }
}
