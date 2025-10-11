import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/asistencia_detalle_model.dart';
import '../models/websocket_event.dart';
import '../providers/asistencia_provider.dart';
import '../services/websocket_pusher_service.dart';

/// Servicio que combina WebSocket con polling inteligente para garantizar tiempo real
class RealtimeAsistenciasService {
  static final RealtimeAsistenciasService _instance = RealtimeAsistenciasService._internal();
  factory RealtimeAsistenciasService() => _instance;
  RealtimeAsistenciasService._internal();

  final WebSocketPusherService _webSocketService = WebSocketPusherService();

  // Estado interno
  Timer? _pollingTimer;
  bool _isWebSocketConnected = false;
  bool _isPollingActive = false;
  bool _isUpdating = false;
  DateTime? _lastUpdate;
  List<AsistenciaDetalle> _lastKnownAsistencias = [];

  // Configuración
  static const Duration _pollingInterval = Duration(seconds: 3);
  static const Duration _maxWebSocketTimeout = Duration(seconds: 30);

  /// Inicializa el servicio en tiempo real
  Future<void> initialize(AsistenciaProvider provider) async {
    debugPrint('🚀 Iniciando RealtimeAsistenciasService...');
    
    // Intentar conectar WebSocket
    await _setupWebSocket(provider);
    
    // Iniciar polling de respaldo
    _startIntelligentPolling(provider);
    
    debugPrint('✅ RealtimeAsistenciasService inicializado');
  }

  /// Configura el WebSocket
  Future<void> _setupWebSocket(AsistenciaProvider provider) async {
    try {
      await _webSocketService.initialize();
      _webSocketService.subscribeToAllChannels();
      
      // Escuchar cambios de estado
      _webSocketService.connectionStateStream.listen((state) {
        _isWebSocketConnected = (state == 'conectado');
        debugPrint('🔗 WebSocket estado: $state');
        
        if (_isWebSocketConnected) {
          _stopPolling();
        } else {
          _startPolling(provider);
        }
      });

      // Escuchar eventos
      _webSocketService.eventStream.listen((event) {
        debugPrint('📡 Evento WebSocket recibido: ${event.event}');
        _handleWebSocketEvent(event, provider);
      });

      // Verificar conexión después de un tiempo
      Timer(_maxWebSocketTimeout, () {
        if (!_isWebSocketConnected) {
          debugPrint('⚠️ WebSocket no conectó en tiempo límite, usando polling');
          _startPolling(provider);
        }
      });

    } catch (e) {
      debugPrint('❌ Error configurando WebSocket: $e');
      _startPolling(provider);
    }
  }

  /// Maneja eventos del WebSocket
  void _handleWebSocketEvent(WebSocketEvent event, AsistenciaProvider provider) {
    if (event.isNuevaAsistencia) {
      debugPrint('🔄 Procesando nueva asistencia desde WebSocket');
      _refreshData(provider);
    }
  }

  /// Inicia polling inteligente
  void _startIntelligentPolling(AsistenciaProvider provider) {
    // Hacer una actualización inicial
    _refreshData(provider);
    
    // Iniciar polling de respaldo después de un delay
    Timer(const Duration(seconds: 5), () {
      if (!_isWebSocketConnected) {
        _startPolling(provider);
      }
    });
  }

  /// Inicia polling activo
  void _startPolling(AsistenciaProvider provider) {
    if (_isPollingActive) return;
    
    _isPollingActive = true;
    debugPrint('🔄 Iniciando polling cada ${_pollingInterval.inSeconds}s');
    
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _refreshData(provider);
    });
  }

  /// Detiene el polling
  void _stopPolling() {
    if (!_isPollingActive) return;
    
    _isPollingActive = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('⏹️ Polling detenido - WebSocket activo');
  }

  /// Actualiza los datos
  Future<void> _refreshData(AsistenciaProvider provider) async {
    // Protección contra llamadas superpuestas
    if (_isUpdating) {
      debugPrint('⏸️ Actualización ya en curso, omitiendo...');
      return;
    }
    
    _isUpdating = true;
    
    try {
      final now = DateTime.now();
      
      // Evitar actualizaciones muy frecuentes
      if (_lastUpdate != null && 
          now.difference(_lastUpdate!).inSeconds < 2) {
        return;
      }

      debugPrint('🔄 Actualizando datos...');
      
      // Obtener asistencias actuales
      await provider.cargarAsistencias();
      final currentAsistencias = provider.asistenciasDetalle;
      
      // Verificar si hay cambios reales
      if (_hasChanges(currentAsistencias)) {
        debugPrint('📊 Cambios detectados: ${currentAsistencias.length} asistencias');
        _lastKnownAsistencias = List.from(currentAsistencias);
        _lastUpdate = now;
        
        // Notificar cambios - el provider ya se notifica automáticamente
      } else {
        debugPrint('ℹ️ Sin cambios reales en los datos');
      }
      
    } catch (e) {
      debugPrint('❌ Error actualizando datos: $e');
    } finally {
      _isUpdating = false;
    }
  }

  /// Verifica si hay cambios reales en las asistencias
  /// Usa comparación por ID en lugar de por índice para evitar falsos positivos
  bool _hasChanges(List<AsistenciaDetalle> currentAsistencias) {
    // Si cambia la cantidad, definitivamente hay cambios
    if (_lastKnownAsistencias.length != currentAsistencias.length) {
      debugPrint('🔄 Cambio de cantidad: ${_lastKnownAsistencias.length} → ${currentAsistencias.length}');
      return true;
    }
    
    // Crear un mapa por ID para comparación rápida e independiente del orden
    final lastMap = {
      for (var a in _lastKnownAsistencias) 
        a.id: '${a.estado}|${a.horaSalida ?? ""}',
    };

    // Verificar si algún ID cambió su estado o hora de salida
    for (var a in currentAsistencias) {
      final currentKey = '${a.estado}|${a.horaSalida ?? ""}';
      
      if (!lastMap.containsKey(a.id)) {
        // Nueva asistencia
        debugPrint('➕ Nueva asistencia detectada: ID ${a.id}');
        return true;
      }
      
      if (lastMap[a.id] != currentKey) {
        // Estado o hora de salida cambió
        debugPrint('🔄 Cambio en asistencia ID ${a.id}: ${lastMap[a.id]} → $currentKey');
        return true;
      }
    }
    
    return false;
  }

  /// Fuerza una actualización inmediata
  Future<void> forceRefresh(AsistenciaProvider provider) async {
    debugPrint('🚀 Forzando actualización inmediata...');
    _lastUpdate = null; // Resetear timestamp
    await _refreshData(provider);
  }

  /// Obtiene el estado del servicio
  Map<String, dynamic> getStatus() {
    return {
      'webSocketConnected': _isWebSocketConnected,
      'pollingActive': _isPollingActive,
      'lastUpdate': _lastUpdate?.toIso8601String(),
      'asistenciasCount': _lastKnownAsistencias.length,
    };
  }

  /// Limpia los recursos
  void dispose() {
    _stopPolling();
    _webSocketService.dispose();
  }
}
