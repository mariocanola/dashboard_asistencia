import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/websocket_event.dart';
import '../utils/websocket_constants.dart';

/// Servicio WebSocket ultra-robusto con reconexión automática y fallback a polling
class RobustWebSocketService {
  static final RobustWebSocketService _instance = RobustWebSocketService._internal();
  factory RobustWebSocketService() => _instance;
  RobustWebSocketService._internal();

  // Conexión WebSocket
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  // Estado de la conexión
  String _connectionState = WebSocketConstants.estadoDesconectado;
  bool _isPollingActive = false;
  bool _isHeartbeatActive = false;

  // Configuración de reconexión con backoff progresivo
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _pollingTimer;
  Timer? _syncTimer;

  // Configuración de timeouts y intervalos
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _pollingInterval = Duration(seconds: 2);
  static const Duration _syncInterval = Duration(seconds: 60);
  static const Duration _connectionTimeout = Duration(seconds: 10);
  static const int _maxReconnectAttempts = 10;

  // Streams para notificar cambios
  final StreamController<String> _connectionStateController = StreamController<String>.broadcast();
  final StreamController<WebSocketEvent> _eventController = StreamController<WebSocketEvent>.broadcast();
  final StreamController<bool> _pollingStateController = StreamController<bool>.broadcast();

  // Notificaciones locales
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Cache de eventos para sincronización
  final List<WebSocketEvent> _eventCache = [];
  DateTime? _lastSyncTime;

  // Getters
  String get connectionState => _connectionState;
  Stream<String> get connectionStateStream => _connectionStateController.stream;
  Stream<WebSocketEvent> get eventStream => _eventController.stream;
  Stream<bool> get pollingStateStream => _pollingStateController.stream;
  bool get isConnected => _connectionState == WebSocketConstants.estadoConectado;
  bool get isPollingActive => _isPollingActive;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Inicializa el servicio WebSocket robusto
  Future<void> initialize() async {
    await _initializeNotifications();
    await connect();
    _startPeriodicSync();
  }

  /// Conecta al servidor WebSocket con reconexión automática
  Future<void> connect() async {
    if (_connectionState == WebSocketConstants.estadoConectando || 
        _connectionState == WebSocketConstants.estadoConectado) {
      return;
    }

    _updateConnectionState(WebSocketConstants.estadoConectando);

    try {
      // Construir URL compatible con Pusher
      final wsUrl = 'ws://${WebSocketConstants.host}:${WebSocketConstants.port}/app/${WebSocketConstants.key}';
      debugPrint('🔗 Conectando a: $wsUrl');

      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: ['pusher'],
      );

      // Configurar timeout de conexión
      final connectionTimeout = Timer(_connectionTimeout, () {
        if (_connectionState == WebSocketConstants.estadoConectando) {
          _handleConnectionError('Timeout de conexión');
        }
      });

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (error, stackTrace) => _handleConnectionError(error.toString()),
        onDone: _handleConnectionClosed,
      );

      // Cancelar timeout si la conexión es exitosa
      await _waitForConnection();
      connectionTimeout.cancel();

      _updateConnectionState(WebSocketConstants.estadoConectado);
      _reconnectAttempts = 0;
      _startHeartbeat();
      _stopPolling(); // Detener polling cuando WebSocket se conecta

      debugPrint('✅ WebSocket robusto conectado exitosamente');

    } catch (e) {
      _handleConnectionError('Error de conexión: $e');
    }
  }

  /// Desconecta del servidor WebSocket
  Future<void> disconnect() async {
    _stopHeartbeat();
    _stopPolling();
    _cancelReconnectTimer();
    _cancelSyncTimer();

    await _subscription?.cancel();
    await _channel?.sink.close();

    _subscription = null;
    _channel = null;

    _updateConnectionState(WebSocketConstants.estadoDesconectado);
    debugPrint('🔌 WebSocket robusto desconectado');
  }

  /// Suscribe a todos los canales
  void subscribeToAllChannels() {
    if (!isConnected) return;

    for (final canal in WebSocketConstants.canales) {
      _subscribeToChannel(canal);
    }
  }

  /// Suscribe a un canal específico
  void _subscribeToChannel(String canal) {
    if (!isConnected) return;

    final subscribeMessage = {
      'event': 'pusher:subscribe',
      'data': {'channel': canal}
    };

    _sendMessage(subscribeMessage);
    debugPrint('📡 Suscrito al canal: $canal');
  }

  /// Maneja mensajes recibidos del WebSocket
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final event = data['event'] as String?;
      final channel = data['channel'] as String?;

      debugPrint('📨 Mensaje WebSocket recibido: $event en canal $channel');

      // Manejar eventos del sistema Pusher
      if (event == 'pusher:connection_established') {
        debugPrint('✅ Conexión Pusher establecida');
        subscribeToAllChannels();
        return;
      }

      if (event == 'pusher:subscription_succeeded') {
        debugPrint('✅ Suscripción exitosa al canal: $channel');
        return;
      }

      // Manejar eventos de aplicación
      if (event != null && channel != null) {
        final eventData = data['data'];
        final webSocketEvent = WebSocketEvent.fromJson({
          'event': event,
          'channel': channel,
          'data': eventData,
        });

        // Agregar a cache para sincronización
        _eventCache.add(webSocketEvent);
        if (_eventCache.length > 100) {
          _eventCache.removeAt(0); // Mantener solo los últimos 100 eventos
        }

        // Emitir evento inmediatamente
        _eventController.add(webSocketEvent);
        debugPrint('📡 Evento emitido: ${webSocketEvent.event}');
      }

    } catch (e) {
      debugPrint('❌ Error procesando mensaje WebSocket: $e');
    }
  }

  /// Envía un mensaje al WebSocket
  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null && isConnected) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  /// Espera a que la conexión se establezca
  Future<void> _waitForConnection() async {
    int attempts = 0;
    while (_connectionState == WebSocketConstants.estadoConectando && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  /// Maneja errores de conexión
  void _handleConnectionError(String error) {
    debugPrint('❌ Error WebSocket robusto: $error');
    _updateConnectionState(WebSocketConstants.estadoError);
    _scheduleReconnect();
  }

  /// Maneja cierre de conexión
  void _handleConnectionClosed() {
    debugPrint('🔌 Conexión WebSocket robusto cerrada');
    _updateConnectionState(WebSocketConstants.estadoDesconectado);
    _scheduleReconnect();
  }

  /// Programa reconexión con backoff progresivo
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('❌ Máximo número de intentos de reconexión alcanzado');
      _startPolling(); // Activar fallback a polling
      return;
    }

    _cancelReconnectTimer();

    // Backoff progresivo: 1s, 2s, 4s, 8s, 16s, 32s, 60s, 60s...
    final delay = min(pow(2, _reconnectAttempts).toInt(), 60);
    _reconnectAttempts++;

    debugPrint('🔄 Programando reconexión en ${delay}s (intento $_reconnectAttempts/$_maxReconnectAttempts)');

    _reconnectTimer = Timer(Duration(seconds: delay), () {
      _updateConnectionState(WebSocketConstants.estadoReconectando);
      connect();
    });
  }

  /// Cancela el timer de reconexión
  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Inicia heartbeat/ping cada 30s
  void _startHeartbeat() {
    _stopHeartbeat();
    _isHeartbeatActive = true;

    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (isConnected) {
        _sendPing();
      } else {
        _stopHeartbeat();
      }
    });

    debugPrint('💓 Heartbeat iniciado cada ${_heartbeatInterval.inSeconds}s');
  }

  /// Detiene el heartbeat
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _isHeartbeatActive = false;
  }

  /// Envía ping para mantener la conexión viva
  void _sendPing() {
    if (isConnected) {
      _sendMessage({'event': 'pusher:ping'});
      debugPrint('💓 Ping enviado');
    }
  }

  /// Inicia polling de fallback cuando WebSocket falla
  void _startPolling() {
    if (_isPollingActive) return;

    _isPollingActive = true;
    _pollingStateController.add(true);

    debugPrint('🔄 Iniciando polling de fallback cada ${_pollingInterval.inSeconds}s');

    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      if (!isConnected) {
        _triggerPollingEvent();
      } else {
        _stopPolling(); // Detener polling cuando WebSocket se reconecta
      }
    });
  }

  /// Detiene el polling
  void _stopPolling() {
    if (!_isPollingActive) return;

    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPollingActive = false;
    _pollingStateController.add(false);

    debugPrint('⏹️ Polling de fallback detenido');
  }

  /// Dispara evento de polling para que el provider actualice datos
  void _triggerPollingEvent() {
    final pollingEvent = WebSocketEvent(
      event: '.PollingFallback',
      channel: WebSocketConstants.canalAsistencias,
      data: {
        'tipo': 'polling',
        'timestamp': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now(),
    );

    _eventController.add(pollingEvent);
    debugPrint('🔄 Evento de polling disparado');
  }

  /// Inicia sincronización periódica cada 60s
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      _triggerSyncEvent();
    });

    debugPrint('🔄 Sincronización periódica iniciada cada ${_syncInterval.inSeconds}s');
  }

  /// Cancela el timer de sincronización
  void _cancelSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Dispara evento de sincronización para validar datos
  void _triggerSyncEvent() {
    _lastSyncTime = DateTime.now();
    
    final syncEvent = WebSocketEvent(
      event: '.SyncValidation',
      channel: WebSocketConstants.canalAsistencias,
      data: {
        'tipo': 'sync',
        'timestamp': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now(),
    );

    _eventController.add(syncEvent);
    debugPrint('🔄 Evento de sincronización disparado');
  }

  /// Actualiza el estado de conexión
  void _updateConnectionState(String newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      _connectionStateController.add(newState);
      debugPrint('🔄 Estado WebSocket: $newState');
    }
  }

  /// Inicializa notificaciones locales
  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  /// Obtiene estadísticas del servicio
  Map<String, dynamic> getStats() {
    return {
      'connectionState': _connectionState,
      'isConnected': isConnected,
      'isPollingActive': _isPollingActive,
      'isHeartbeatActive': _isHeartbeatActive,
      'reconnectAttempts': _reconnectAttempts,
      'eventCacheSize': _eventCache.length,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
    };
  }

  /// Limpia recursos
  void dispose() {
    disconnect();
    _connectionStateController.close();
    _eventController.close();
    _pollingStateController.close();
  }
}
