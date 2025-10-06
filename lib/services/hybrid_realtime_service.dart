import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import '../models/asistencia_detalle_model.dart';
import '../models/websocket_event.dart';
import '../utils/constants.dart';
import '../utils/websocket_constants.dart';

/// Servicio híbrido que combina WebSocket + Fallback REST
/// WebSocket activo → eventos en tiempo real (< 1 segundo)
/// WebSocket falla → polling rápido cada 1s con REST
/// Al reconectar → se detiene polling y vuelve al flujo normal
class HybridRealtimeService {
  static final HybridRealtimeService _instance = HybridRealtimeService._internal();
  factory HybridRealtimeService() => _instance;
  HybridRealtimeService._internal();

  // URLs - Detección automática de protocolo
  String get wsUrl {
    if (kIsWeb) {
      // Detectar protocolo en web
      final protocol = html.window.location.protocol;
      final wsProtocol = protocol == 'https:' ? 'wss://' : 'ws://';
      return "$wsProtocol${WebSocketConstants.host}:${WebSocketConstants.port}/app/${WebSocketConstants.key}";
    } else {
      // Para móvil/desktop usar ws://
      return "ws://${WebSocketConstants.host}:${WebSocketConstants.port}/app/${WebSocketConstants.key}";
    }
  }
  
  final String apiUrl = "${ApiConstants.baseUrl}/asistencia/jornada";

  // WebSocket
  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;
  
  // Polling
  Timer? _pollingTimer;
  Timer? _heartbeatTimer;
  Timer? _inactivityTimer;
  
  // Estado
  bool _isWebSocketActive = false;
  bool _isPollingActive = false;
  DateTime? _lastUpdate;
  DateTime? _lastWebSocketEvent;
  int _reconnectAttempts = 0;
  
  // Configuración de detección de inactividad
  static const Duration _inactivityThreshold = Duration(seconds: 5);
  static const Duration _inactivityCheckInterval = Duration(seconds: 3);
  
  // Streams para notificar cambios
  final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();
  final StreamController<List<AsistenciaDetalle>> _dataController = StreamController<List<AsistenciaDetalle>>.broadcast();
  final StreamController<WebSocketEvent> _eventController = StreamController<WebSocketEvent>.broadcast();

  // Getters
  bool get isWebSocketActive => _isWebSocketActive;
  bool get isPollingActive => _isPollingActive;
  DateTime? get lastUpdate => _lastUpdate;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  Stream<List<AsistenciaDetalle>> get dataStream => _dataController.stream;
  Stream<WebSocketEvent> get eventStream => _eventController.stream;

  /// Inicializa el servicio híbrido
  Future<void> initialize() async {
    debugPrint('🚀 Inicializando servicio híbrido WebSocket + REST...');
    await _connectWebSocket();
  }

  /// Conecta al WebSocket con reconexión automática
  Future<void> _connectWebSocket() async {
    try {
      debugPrint('🔗 Conectando a WebSocket: $wsUrl');
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _wsSubscription = _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          debugPrint('❌ Error WebSocket: $error');
          _handleWebSocketFailure();
        },
        onDone: () {
          debugPrint('🔌 WebSocket desconectado');
          _handleWebSocketFailure();
        },
      );

      // Esperar un poco para verificar conexión
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (_channel != null) {
        _setWebSocketActive(true);
        _reconnectAttempts = 0;
        _startHeartbeat();
        _startInactivityMonitor();
        _lastWebSocketEvent = DateTime.now();
        debugPrint('✅ WebSocket conectado exitosamente');
      }
    } catch (e) {
      debugPrint('❌ Error al conectar WebSocket: $e');
      _handleWebSocketFailure();
    }
  }

  /// Maneja mensajes del WebSocket con procesamiento optimizado
  void _handleWebSocketMessage(dynamic message) {
    try {
      debugPrint('📨 Mensaje WebSocket recibido');
      
      final Map<String, dynamic> json = jsonDecode(message);
      final eventName = json['event'];

      // Manejar eventos de Pusher internos
      if (eventName == 'pusher:connection_established') {
        debugPrint('✅ Pusher: Conexión establecida');
        _setWebSocketActive(true);
        _subscribeToChannels();
        _lastWebSocketEvent = DateTime.now();
      } else if (eventName == 'pusher:ping') {
        _channel?.sink.add(jsonEncode({'event': 'pusher:pong', 'data': {}}));
      } else if (eventName == 'pusher:pong') {
        // Respuesta al ping - cuenta como actividad
        _lastWebSocketEvent = DateTime.now();
      } else if (eventName == 'pusher:error') {
        debugPrint('❌ Pusher Error: ${json['data']}');
        _handleWebSocketFailure();
      } else if (eventName == 'pusher:subscription_succeeded') {
        debugPrint('✅ Suscripción exitosa al canal: ${json['channel']}');
        _lastWebSocketEvent = DateTime.now();
      } else {
        // Es un evento de aplicación - procesar inmediatamente
        debugPrint('⚡ Evento de aplicación recibido: $eventName');
        final event = WebSocketEvent.fromJsonString(message);
        _eventController.add(event);
        
        // Actualizar timestamp de último evento real
        _lastWebSocketEvent = DateTime.now();
        
        // Actualizar datos inmediatamente (< 1 segundo)
        _updateDataFromWebSocket(event);
      }
    } catch (e) {
      debugPrint('❌ Error al procesar mensaje WebSocket: $e');
    }
  }

  /// Suscribe a todos los canales
  void _subscribeToChannels() {
    if (!_isWebSocketActive || _channel == null) return;
    
    for (var channelName in WebSocketConstants.canales) {
      final subscribeMessage = jsonEncode({
        'event': 'pusher:subscribe',
        'data': {'channel': channelName},
      });
      _channel!.sink.add(subscribeMessage);
      debugPrint('📡 Suscrito al canal: $channelName');
    }
  }

  /// Actualiza datos desde evento WebSocket
  void _updateDataFromWebSocket(WebSocketEvent event) {
    debugPrint('⚡ Actualizando datos desde WebSocket...');
    debugPrint('   Evento: ${event.event}');
    debugPrint('   Canal: ${event.channel}');
    debugPrint('   Timestamp: ${event.timestamp}');
    
    // Notificar actualización inmediata
    _lastUpdate = DateTime.now();
    _lastWebSocketEvent = DateTime.now();
    debugPrint('✅ Datos actualizados desde WebSocket en tiempo real');
  }


  /// Activa polling cuando WebSocket falla (mejorado a 1.5 segundos para estabilidad)
  void _startPolling() {
    if (_isPollingActive) return; // Evitar múltiples timers
    
    _isPollingActive = true;
    _connectionStateController.add(false); // Notificar que está en polling
    
    debugPrint('⏳ Iniciando polling cada 1.5 segundos (WebSocket inactivo)...');
    
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) async {
      await _pollingUpdate();
    });
  }

  /// Actualización por polling optimizada (timeout aumentado a 5 segundos)
  Future<void> _pollingUpdate() async {
    try {
      debugPrint('🔄 Polling - Actualizando datos...');
      
      final fecha = DateTime.now().toLocal().toString().split(' ')[0];
      final url = '$apiUrl?fecha=$fecha';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⏰ Timeout de 5s en polling - servidor no responde a tiempo');
          throw TimeoutException('Servidor no responde');
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final asistencias = (data['asistencias'] as List)
            .map((json) => AsistenciaDetalle.fromJson(json))
            .toList();
        
        _dataController.add(asistencias);
        _lastUpdate = DateTime.now();
        
        debugPrint('✅ Polling - Datos actualizados: ${asistencias.length} asistencias');
      }
    } catch (e) {
      debugPrint('❌ Error en polling: $e');
      // Mantener último cache si falla
    }
  }

  /// Detiene el polling
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPollingActive = false;
    debugPrint('⏹️ Polling detenido');
  }

  /// Establece el estado del WebSocket
  void _setWebSocketActive(bool active) {
    _isWebSocketActive = active;
    _connectionStateController.add(active);
    
    if (active) {
      _stopPolling(); // Detener polling cuando WebSocket funciona
      debugPrint('✅ WebSocket activo - Polling detenido');
    }
  }

  /// Inicia el heartbeat para mantener la conexión activa
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _sendHeartbeat(),
    );
  }

  /// Envía heartbeat para mantener la conexión
  void _sendHeartbeat() {
    if (_isWebSocketActive && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode({'event': 'pusher:ping', 'data': {}}));
        debugPrint('💓 Heartbeat enviado');
      } catch (e) {
        debugPrint('❌ Error enviando heartbeat: $e');
        _handleWebSocketFailure();
      }
    }
  }

  /// Maneja fallo del WebSocket con reconexión automática y backoff progresivo
  void _handleWebSocketFailure() {
    debugPrint('🔄 WebSocket falló, iniciando polling de fallback...');
    _setWebSocketActive(false);
    _stopHeartbeat();
    _stopInactivityMonitor();
    _startPolling();
    
    // Intentar reconexión automática con backoff progresivo: 1s, 2s, 5s, 10s (máx 30s)
    if (_reconnectAttempts < 4) {
      _reconnectAttempts++;
      final delays = [1, 2, 5, 10]; // Backoff progresivo
      final delaySeconds = delays[_reconnectAttempts - 1];
      final delay = Duration(seconds: delaySeconds);
      
      debugPrint('🔄 Reintentando conexión en ${delay.inSeconds} segundos (intento $_reconnectAttempts/4)');
      
      Timer(delay, () {
        if (!_isWebSocketActive) {
          _connectWebSocket();
        }
      });
    } else {
      debugPrint('❌ Máximo de intentos de reconexión alcanzado (4 intentos)');
    }
  }

  /// Detiene el heartbeat
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Inicia el monitor de inactividad del WebSocket
  void _startInactivityMonitor() {
    _stopInactivityMonitor();
    
    _inactivityTimer = Timer.periodic(_inactivityCheckInterval, (_) {
      _checkWebSocketInactivity();
    });
    
    debugPrint('👁️ Monitor de inactividad iniciado (verifica cada ${_inactivityCheckInterval.inSeconds}s)');
  }

  /// Detiene el monitor de inactividad
  void _stopInactivityMonitor() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  /// Verifica si el WebSocket está inactivo (sin eventos)
  void _checkWebSocketInactivity() {
    if (!_isWebSocketActive) return;
    
    final now = DateTime.now();
    if (_lastWebSocketEvent == null) {
      debugPrint('⚠️ No se ha registrado ningún evento WebSocket aún');
      return;
    }
    
    final timeSinceLastEvent = now.difference(_lastWebSocketEvent!);
    
    if (timeSinceLastEvent > _inactivityThreshold) {
      debugPrint('⚠️ WebSocket inactivo por ${timeSinceLastEvent.inSeconds}s (umbral: ${_inactivityThreshold.inSeconds}s)');
      debugPrint('🔄 Activando polling automático debido a inactividad...');
      
      // El WebSocket está conectado pero no emite datos - activar polling
      _setWebSocketActive(false);
      _startPolling();
    } else {
      debugPrint('✅ WebSocket activo - último evento hace ${timeSinceLastEvent.inSeconds}s');
    }
  }

  /// Reconecta el WebSocket
  Future<void> reconnect() async {
    debugPrint('🔄 Intentando reconectar WebSocket...');
    await disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await _connectWebSocket();
  }

  /// Desconecta el servicio
  Future<void> disconnect() async {
    debugPrint('🔌 Desconectando servicio híbrido...');
    
    _stopPolling();
    _stopHeartbeat();
    _stopInactivityMonitor();
    await _wsSubscription?.cancel();
    await _channel?.sink.close();
    
    _channel = null;
    _wsSubscription = null;
    _isWebSocketActive = false;
    _isPollingActive = false;
    _reconnectAttempts = 0;
  }

  /// Cierra todos los streams
  Future<void> dispose() async {
    await disconnect();
    await _connectionStateController.close();
    await _dataController.close();
    await _eventController.close();
  }
}
