import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/asistencia_detalle_model.dart';
import '../models/websocket_event.dart';
import '../providers/asistencia_provider.dart';
import '../services/websocket_pusher_service.dart';

/// Servicio ultra-optimizado para manejar miles de asistencias en tiempo real
/// Máximo 5 segundos de actualización, optimizado para alta carga
class UltraFastAsistenciasService {
  static final UltraFastAsistenciasService _instance =
      UltraFastAsistenciasService._internal();
  factory UltraFastAsistenciasService() => _instance;
  UltraFastAsistenciasService._internal();

  final WebSocketPusherService _webSocketService = WebSocketPusherService();

  // Estado interno optimizado
  Timer? _fastPollingTimer;
  Timer? _webSocketHealthTimer;
  bool _isWebSocketConnected = false;
  bool _isFastPollingActive = false;

  // Cache optimizado
  Map<int, AsistenciaDetalle> _asistenciasCache = {};
  Set<int> _changedIds = {};
  DateTime? _lastUpdate;
  int _lastCount = 0;

  // Configuración ultra-rápida optimizada para máximo 1 segundo
  static const Duration _fastPollingInterval =
      Duration(milliseconds: 500); // Reducido a 500ms para respuesta más rápida
  static const Duration _webSocketTimeout =
      Duration(seconds: 5); // Reducido a 5s
  static const Duration _healthCheckInterval =
      Duration(seconds: 30); // Health check cada 30s
  // static const int _maxBatchSize = 50; // Procesar máximo 50 cambios por vez

  /// Inicializa el servicio ultra-rápido
  Future<void> initialize(AsistenciaProvider provider) async {
    debugPrint('🚀 Iniciando UltraFastAsistenciasService...');

    // Inicializar cache
    _initializeCache(provider);

    // Configurar WebSocket optimizado
    await _setupOptimizedWebSocket(provider);

    // Iniciar polling ultra-rápido
    _startUltraFastPolling(provider);

    debugPrint(
        '✅ UltraFastAsistenciasService inicializado - Máximo 3s de delay');
  }

  /// Inicializa el cache con datos actuales
  void _initializeCache(AsistenciaProvider provider) {
    final asistencias = provider.asistenciasDetalle;
    _asistenciasCache.clear();
    _changedIds.clear();

    for (var asistencia in asistencias) {
      _asistenciasCache[asistencia.id] = asistencia;
    }

    _lastCount = asistencias.length;
    _lastUpdate = DateTime.now();

    debugPrint('📊 Cache inicializado: ${asistencias.length} asistencias');
  }

  /// Configura WebSocket optimizado
  Future<void> _setupOptimizedWebSocket(AsistenciaProvider provider) async {
    try {
      await _webSocketService.initialize();
      _webSocketService.subscribeToAllChannels();

      // Health check del WebSocket optimizado (cada 30s)
      _webSocketHealthTimer = Timer.periodic(_healthCheckInterval, (_) {
        _checkWebSocketHealth(provider);
      });

      // Escuchar eventos WebSocket
      _webSocketService.eventStream.listen((event) {
        debugPrint('⚡ Evento WebSocket recibido: ${event.event}');
        _handleWebSocketEvent(event, provider);
      });

      // Escuchar cambios de estado
      _webSocketService.connectionStateStream.listen((state) {
        _isWebSocketConnected = (state == 'conectado');

        if (_isWebSocketConnected) {
          _stopFastPolling();
          debugPrint('🟢 WebSocket activo - Polling pausado');
        } else {
          _startFastPolling(provider);
          debugPrint('🟡 WebSocket inactivo - Polling activado');
        }
      });

      // Timeout para WebSocket
      Timer(_webSocketTimeout, () {
        if (!_isWebSocketConnected) {
          debugPrint('⏰ WebSocket timeout - Usando polling ultra-rápido');
          _startFastPolling(provider);
        }
      });
    } catch (e) {
      debugPrint('❌ Error configurando WebSocket: $e');
      _startFastPolling(provider);
    }
  }

  /// Verifica la salud del WebSocket (optimizado)
  void _checkWebSocketHealth(AsistenciaProvider provider) {
    if (_isWebSocketConnected) {
      // Solo actualizar si han pasado más de 30 segundos sin eventos
      final now = DateTime.now();
      if (_lastUpdate == null || now.difference(_lastUpdate!).inSeconds > 30) {
        debugPrint('🔍 WebSocket health check - Actualizando datos (cada 30s)');
        _fastUpdate(provider);
      }
    }
  }

  /// Maneja eventos del WebSocket
  void _handleWebSocketEvent(
      WebSocketEvent event, AsistenciaProvider provider) {
    if (event.isNuevaAsistencia) {
      debugPrint('⚡ Procesando nueva asistencia desde WebSocket');
      _fastUpdate(provider);
    }
  }

  /// Inicia polling ultra-rápido
  void _startUltraFastPolling(AsistenciaProvider provider) {
    if (_isFastPollingActive) return;

    _isFastPollingActive = true;
    debugPrint(
        '⚡ Iniciando polling ultra-rápido cada ${_fastPollingInterval.inSeconds}s');

    // Actualización inmediata
    _fastUpdate(provider);

    // Polling regular
    _fastPollingTimer = Timer.periodic(_fastPollingInterval, (_) {
      _fastUpdate(provider);
    });
  }

  /// Inicia polling rápido
  void _startFastPolling(AsistenciaProvider provider) {
    if (_isFastPollingActive) return;

    _isFastPollingActive = true;
    debugPrint(
        '🔄 Iniciando polling rápido cada ${_fastPollingInterval.inSeconds}s');

    _fastPollingTimer = Timer.periodic(_fastPollingInterval, (_) {
      _fastUpdate(provider);
    });
  }

  /// Detiene el polling
  void _stopFastPolling() {
    if (!_isFastPollingActive) return;

    _isFastPollingActive = false;
    _fastPollingTimer?.cancel();
    _fastPollingTimer = null;
    debugPrint('⏹️ Polling detenido - WebSocket activo');
  }

  /// Actualización ultra-rápida optimizada para máximo 1 segundo
  Future<void> _fastUpdate(AsistenciaProvider provider) async {
    try {
      final startTime = DateTime.now();
      debugPrint('⚡ Iniciando actualización ultra-rápida...');

      // Actualización con timeout reducido a 1 segundo
      await provider.cargarAsistencias().timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          debugPrint('⏰ Timeout en carga de asistencias - usando cache');
        },
      );

      final currentAsistencias = provider.asistenciasDetalle;

      // Detección ultra-rápida de cambios
      final changes = _detectChangesFast(currentAsistencias);

      if (changes.isNotEmpty) {
        final updateTime = DateTime.now().difference(startTime).inMilliseconds;
        debugPrint(
            '⚡ Cambios detectados: ${changes.length} asistencias en ${updateTime}ms');

        // Actualizar cache inmediatamente
        _updateCache(changes);
        _lastUpdate = DateTime.now();

        debugPrint('✅ Actualización ultra-rápida completada en ${updateTime}ms');
      }
    } catch (e) {
      debugPrint('❌ Error en actualización ultra-rápida: $e');
      // Intentar actualización de respaldo más rápida
      await _ultraFastBackupUpdate(provider);
    }
  }

  /// Actualización de respaldo ultra-rápida (500ms máximo)
  Future<void> _ultraFastBackupUpdate(AsistenciaProvider provider) async {
    try {
      debugPrint('🔄 Ejecutando actualización de respaldo ultra-rápida...');
      
      // Solo cargar asistencias con timeout muy corto
      await provider.cargarAsistencias().timeout(const Duration(milliseconds: 500));
      
      debugPrint('✅ Actualización de respaldo ultra-rápida completada');
    } catch (e) {
      debugPrint('❌ Error en actualización de respaldo ultra-rápida: $e');
    }
  }

  /// Detección ultra-rápida de cambios
  List<AsistenciaDetalle> _detectChangesFast(
      List<AsistenciaDetalle> currentAsistencias) {
    final changes = <AsistenciaDetalle>[];

    // Verificación rápida por cantidad
    if (currentAsistencias.length != _lastCount) {
      debugPrint(
          '📊 Cambio de cantidad: ${_lastCount} → ${currentAsistencias.length}');
      _lastCount = currentAsistencias.length;
      return currentAsistencias; // Retornar todas si cambió la cantidad
    }

    // Verificación rápida por IDs y estados
    for (var asistencia in currentAsistencias) {
      final cached = _asistenciasCache[asistencia.id];

      if (cached == null) {
        // Nueva asistencia
        changes.add(asistencia);
      } else if (cached.estado != asistencia.estado ||
          cached.horaSalida != asistencia.horaSalida) {
        // Asistencia modificada
        changes.add(asistencia);
      }
    }

    return changes;
  }

  /// Actualiza el cache de manera eficiente
  void _updateCache(List<AsistenciaDetalle> changes) {
    for (var asistencia in changes) {
      _asistenciasCache[asistencia.id] = asistencia;
      _changedIds.add(asistencia.id);
    }
  }


  /// Fuerza actualización inmediata
  Future<void> forceRefresh(AsistenciaProvider provider) async {
    debugPrint('🚀 Forzando actualización inmediata...');
    _lastUpdate = null;
    await _fastUpdate(provider);
  }

  /// Obtiene estadísticas del servicio
  Map<String, dynamic> getStatus() {
    return {
      'webSocketConnected': _isWebSocketConnected,
      'fastPollingActive': _isFastPollingActive,
      'lastUpdate': _lastUpdate?.toIso8601String(),
      'cachedAsistencias': _asistenciasCache.length,
      'pendingChanges': _changedIds.length,
      'pollingInterval': _fastPollingInterval.inSeconds,
    };
  }

  /// Obtiene el tiempo de respuesta promedio
  String getResponseTime() {
    if (_lastUpdate == null) return 'N/A';

    final now = DateTime.now();
    final diff = now.difference(_lastUpdate!);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else {
      return '${diff.inHours}h';
    }
  }

  /// Limpia los recursos
  void dispose() {
    _stopFastPolling();
    _webSocketHealthTimer?.cancel();
    _webSocketService.dispose();
    _asistenciasCache.clear();
    _changedIds.clear();
  }
}

