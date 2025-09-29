import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/websocket_event.dart';
import '../utils/websocket_constants.dart';

/// Servicio WebSocket compatible con Pusher usando web_socket_channel
class WebSocketPusherService {
  static final WebSocketPusherService _instance =
      WebSocketPusherService._internal();
  factory WebSocketPusherService() => _instance;
  WebSocketPusherService._internal();

  // Conexión WebSocket
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  // Estado de la conexión
  String _connectionState = WebSocketConstants.estadoDesconectado;

  // Configuración de reconexión
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  // Streams para notificar cambios
  final StreamController<String> _connectionStateController =
      StreamController<String>.broadcast();
  final StreamController<WebSocketEvent> _eventController =
      StreamController<WebSocketEvent>.broadcast();

  // Notificaciones locales
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Getters
  String get connectionState => _connectionState;
  Stream<String> get connectionStateStream => _connectionStateController.stream;
  Stream<WebSocketEvent> get eventStream => _eventController.stream;
  bool get isConnected =>
      _connectionState == WebSocketConstants.estadoConectado;

  /// Inicializa el servicio WebSocket
  Future<void> initialize() async {
    await _initializeNotifications();
    await connect();
  }

  /// Conecta al servidor WebSocket
  Future<void> connect() async {
    if (_connectionState == WebSocketConstants.estadoConectando ||
        _connectionState == WebSocketConstants.estadoConectado) {
      return;
    }

    _updateConnectionState(WebSocketConstants.estadoConectando);

    try {
      // Construir URL compatible con Pusher
      final wsUrl =
          'ws://${WebSocketConstants.host}:${WebSocketConstants.port}/app/${WebSocketConstants.key}';
      debugPrint('🔗 Conectando a: $wsUrl');

      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: ['pusher'],
      );

      // Configurar timeout de conexión
      final connectionTimeout = Timer(
        Duration(seconds: WebSocketConstants.connectionTimeoutSeconds),
        () {
          if (_connectionState == WebSocketConstants.estadoConectando) {
            _handleConnectionError('Timeout de conexión');
          }
        },
      );

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (error, stackTrace) =>
            _handleConnectionError(error.toString()),
        onDone: _handleConnectionClosed,
      );

      // Cancelar timeout si la conexión es exitosa
      await _waitForConnection();
      connectionTimeout.cancel();

      _updateConnectionState(WebSocketConstants.estadoConectado);
      _reconnectAttempts = 0;
      _startHeartbeat();

      debugPrint('✅ WebSocket Pusher conectado exitosamente');
    } catch (e) {
      _handleConnectionError('Error de conexión: $e');
    }
  }

  /// Desconecta del servidor WebSocket
  Future<void> disconnect() async {
    _stopHeartbeat();
    _cancelReconnectTimer();

    await _subscription?.cancel();
    await _channel?.sink.close();

    _subscription = null;
    _channel = null;

    _updateConnectionState(WebSocketConstants.estadoDesconectado);
    debugPrint('🔌 WebSocket Pusher desconectado');
  }

  /// Suscribe a un canal específico
  void subscribeToChannel(String channelName) {
    if (!isConnected || _channel == null) {
      debugPrint('❌ No se puede suscribir: WebSocket no conectado');
      return;
    }

    final subscribeMessage = {
      'event': 'pusher:subscribe',
      'data': {'channel': channelName}
    };

    _channel!.sink.add(jsonEncode(subscribeMessage));
    debugPrint('📡 Suscrito al canal Pusher: $channelName');
  }

  /// Desuscribe de un canal específico
  void unsubscribeFromChannel(String channelName) {
    if (!isConnected || _channel == null) {
      return;
    }

    final unsubscribeMessage = {
      'event': 'pusher:unsubscribe',
      'data': {'channel': channelName}
    };

    _channel!.sink.add(jsonEncode(unsubscribeMessage));
    debugPrint('📡 Desuscrito del canal Pusher: $channelName');
  }

  /// Suscribe a todos los canales configurados
  void subscribeToAllChannels() {
    for (final channel in WebSocketConstants.canales) {
      subscribeToChannel(channel);
    }
  }

  /// Envía un mensaje al servidor
  void sendMessage(Map<String, dynamic> message) {
    if (!isConnected || _channel == null) {
      debugPrint('❌ No se puede enviar mensaje: WebSocket no conectado');
      return;
    }

    _channel!.sink.add(jsonEncode(message));
  }

  /// Libera los recursos del servicio
  void dispose() {
    disconnect();
    _connectionStateController.close();
    _eventController.close();
  }

  // --- Métodos privados ---

  /// Espera a que la conexión se establezca
  Future<void> _waitForConnection() async {
    // En un escenario real con Pusher, aquí esperaríamos el evento de conexión
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Maneja mensajes recibidos del WebSocket
  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message.toString());

      // Manejar eventos de Pusher
      if (data['event'] == 'pusher:connection_established') {
        debugPrint('🔗 Conexión WebSocket Pusher establecida');
        return;
      }

      // Manejar eventos de suscripción
      if (data['event'] == 'pusher:subscription_succeeded') {
        final channel = data['channel'] ?? 'desconocido';
        debugPrint('✅ Suscripción exitosa al canal Pusher: $channel');
        return;
      }

      // Crear evento personalizado
      final event = WebSocketEvent.fromJson(data);

      if (event.hasValidData) {
        _eventController.add(event);
        _showNotification(event);
        debugPrint(
            '📨 Evento Pusher recibido: ${event.event} en canal ${event.channel}');
      } else {
        debugPrint('⚠️ Evento Pusher inválido recibido: $data');
      }
    } catch (e) {
      debugPrint('❌ Error al procesar mensaje WebSocket Pusher: $e');
    }
  }

  /// Maneja errores de conexión
  void _handleConnectionError(String error) {
    debugPrint('❌ Error WebSocket Pusher: $error');
    _updateConnectionState(WebSocketConstants.estadoError);
    _attemptReconnect();
  }

  /// Maneja el cierre de conexión
  void _handleConnectionClosed() {
    debugPrint('🔌 Conexión WebSocket Pusher cerrada');
    _updateConnectionState(WebSocketConstants.estadoDesconectado);
    _attemptReconnect();
  }

  /// Intenta reconectar automáticamente
  void _attemptReconnect() {
    if (_reconnectAttempts >= WebSocketConstants.maxReconnectAttempts) {
      debugPrint('❌ Máximo de intentos de reconexión alcanzado');
      _updateConnectionState(WebSocketConstants.estadoError);
      return;
    }

    _reconnectAttempts++;
    _updateConnectionState(WebSocketConstants.estadoReconectando);

    _reconnectTimer = Timer(
      Duration(seconds: WebSocketConstants.reconnectDelaySeconds),
      () {
        debugPrint(
            '🔄 Intentando reconectar WebSocket Pusher... (${_reconnectAttempts}/${WebSocketConstants.maxReconnectAttempts})');
        connect();
      },
    );
  }

  /// Actualiza el estado de conexión y notifica a los listeners
  void _updateConnectionState(String newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      _connectionStateController.add(newState);
    }
  }

  /// Inicia el heartbeat para mantener la conexión viva
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: WebSocketConstants.heartbeatIntervalSeconds),
      (_) => _sendHeartbeat(),
    );
  }

  /// Detiene el heartbeat
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Envía un mensaje de heartbeat
  void _sendHeartbeat() {
    if (isConnected && _channel != null) {
      final heartbeatMessage = {'event': 'pusher:ping', 'data': {}};
      _channel!.sink.add(jsonEncode(heartbeatMessage));
    }
  }

  /// Cancela el timer de reconexión
  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Inicializa las notificaciones locales
  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  /// Muestra una notificación local para el evento recibido
  Future<void> _showNotification(WebSocketEvent event) async {
    String title;
    String body;

    if (event.isNuevaAsistencia) {
      title = 'Nueva Asistencia Registrada';
      body = 'Ficha ${event.fichaId} - Programa ${event.programa ?? "N/A"}';
    } else if (event.isQrScanned) {
      title = 'QR Escaneado';
      body = 'Ficha ${event.fichaId} - Aprendiz ${event.aprendizId}';
    } else {
      return; // No mostrar notificación para eventos desconocidos
    }

    const androidDetails = AndroidNotificationDetails(
      'websocket_events',
      'Eventos WebSocket',
      channelDescription: 'Notificaciones de eventos en tiempo real',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      event.timestamp.millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
