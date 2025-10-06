import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/asistencia_detalle_model.dart';
import '../models/websocket_event.dart';
import '../services/api_service.dart';
import '../services/robust_websocket_service.dart';

/// Provider robusto para manejo de asistencias con WebSocket resiliente y fallback a polling
class RobustAsistenciaProvider extends ChangeNotifier {
  final ApiService _apiService;
  final RobustWebSocketService _robustWebSocketService = RobustWebSocketService();

  // Estado de datos
  List<AsistenciaDetalle> _asistenciasDetalle = [];
  Map<String, dynamic> _estadisticas = {};
  List<dynamic> _fichas = [];
  final List<WebSocketEvent> _ultimasAsistenciasWS = [];
  String _jornadaActual = '';

  // Estado de carga y errores
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Estado de conexión
  String _webSocketState = 'desconectado';
  bool _isPollingActive = false;
  DateTime? _lastDataUpdate;

  // Subscripciones
  StreamSubscription<String>? _webSocketStateSubscription;
  StreamSubscription<WebSocketEvent>? _webSocketEventSubscription;
  StreamSubscription<bool>? _pollingStateSubscription;
  
  // Timer para polling automático
  Timer? _pollingTimer;

  // Cache para resiliencia
  Map<String, dynamic> _dataCache = {};
  DateTime? _lastCacheUpdate;

  // Getters
  List<AsistenciaDetalle> get asistenciasDetalle => _asistenciasDetalle;
  Map<String, dynamic> get estadisticas => _estadisticas;
  List<dynamic> get fichas => _fichas;
  List<WebSocketEvent> get ultimasAsistenciasWS => _ultimasAsistenciasWS;
  String get jornadaActual => _jornadaActual;
  
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  
  String get webSocketState => _webSocketState;
  bool get isWebSocketConnected => _webSocketState == 'conectado';
  bool get isPollingActive => _isPollingActive;
  DateTime? get lastDataUpdate => _lastDataUpdate;

  RobustAsistenciaProvider({required ApiService apiService}) : _apiService = apiService {
    _init();
  }

  /// Inicialización del provider robusto
  Future<void> _init() async {
    await cargarDatos();
    _configurarWebSocketRobusto();
    _iniciarPollingAutomatico();
  }

  /// Carga todos los datos (método público)
  Future<void> cargarDatos() async {
    await _cargarDatosInternos();
  }

  /// Carga todos los datos iniciales
  Future<void> _cargarDatosInternos() async {
    _setLoading(true);
    _clearError();
    
    try {
      debugPrint('🔄 Cargando datos iniciales...');
      
      // Determinar jornada actual
      _jornadaActual = _determinarJornadaActual();
      
      // Cargar datos en paralelo para mejor rendimiento
      await Future.wait([
        _cargarEstadisticas(),
        _cargarFichas(),
        _cargarAsistencias(),
      ]);

      _lastDataUpdate = DateTime.now();
      _updateCache();
      notifyListeners();
      
      debugPrint('✅ Datos iniciales cargados exitosamente');
    } catch (e) {
      debugPrint('❌ Error al cargar datos iniciales: $e');
      _setError('Error al cargar datos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Inicia el polling automático cada 2 segundos
  void _iniciarPollingAutomatico() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      debugPrint('🔄 Polling automático - Actualizando datos...');
      _actualizarDatosDesdePolling();
    });
    debugPrint('✅ Polling automático iniciado cada 2 segundos');
  }

  /// Detiene el polling automático
  void _detenerPollingAutomatico() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('⏹️ Polling automático detenido');
  }

  /// Determina la jornada actual basada en la hora
  String _determinarJornadaActual() {
    final hora = DateTime.now().hour;
    if (hora >= 6 && hora < 12) {
      return 'MAÑANA';
    } else if (hora >= 12 && hora < 18) {
      return 'TARDE';
    } else if (hora >= 18 && hora < 22) {
      return 'NOCHE';
    } else {
      return 'Fuera de jornada';
    }
  }

  /// Configura el WebSocket robusto
  void _configurarWebSocketRobusto() {
    // Suscribirse a cambios de estado del WebSocket
    _webSocketStateSubscription = _robustWebSocketService.connectionStateStream.listen((state) {
      _webSocketState = state;
      debugPrint('🔄 Estado WebSocket: $state');
      notifyListeners();
    });

    // Suscribirse a eventos del WebSocket
    _webSocketEventSubscription = _robustWebSocketService.eventStream.listen(
      _manejarEventoWebSocket,
      onError: (error) {
        debugPrint('❌ Error en stream de eventos WebSocket: $error');
        _setError('Error en WebSocket: $error');
      },
    );

    // Suscribirse a cambios de estado de polling
    _pollingStateSubscription = _robustWebSocketService.pollingStateStream.listen((isPolling) {
      _isPollingActive = isPolling;
      debugPrint('🔄 Estado polling: $isPolling');
      notifyListeners();
    });

    // Inicializar WebSocket robusto
    _inicializarWebSocketRobusto();
  }

  /// Inicializa la conexión WebSocket robusta
  Future<void> _inicializarWebSocketRobusto() async {
    try {
      await _robustWebSocketService.initialize();
      debugPrint('✅ WebSocket robusto configurado');
    } catch (e) {
      debugPrint('❌ Error al inicializar WebSocket robusto: $e');
      _setError('Error al conectar WebSocket: $e');
    }
  }

  /// Maneja eventos recibidos del WebSocket robusto
  void _manejarEventoWebSocket(WebSocketEvent event) {
    try {
      debugPrint('📨 Procesando evento WebSocket robusto: ${event.event}');
      
      if (event.isNuevaAsistencia) {
        _procesarNuevaAsistencia(event);
      } else if (event.isQrScanned) {
        _procesarQrScanned(event);
      } else if (event.event == '.PollingFallback') {
        _procesarPollingFallback(event);
      } else if (event.event == '.SyncValidation') {
        _procesarSyncValidation(event);
      }

    } catch (e) {
      debugPrint('❌ Error al procesar evento WebSocket: $e');
    }
  }

  /// Procesa eventos de nueva asistencia registrada (actualización inmediata)
  void _procesarNuevaAsistencia(WebSocketEvent event) {
    debugPrint(
      '📝 Nueva asistencia recibida - ID: ${event.asistenciaId}, '
      'Aprendiz: ${event.aprendizNombre}, '
      'Estado: ${event.estadoAsistencia}, '
      'Ficha: ${event.fichaId}, '
      'Jornada: ${event.jornada}',
    );

    // Agregar a la lista de últimas asistencias
    _ultimasAsistenciasWS.insert(0, event);
    if (_ultimasAsistenciasWS.length > 10) {
      _ultimasAsistenciasWS.removeRange(10, _ultimasAsistenciasWS.length);
    }

    // ⚡ ACTUALIZACIÓN INMEDIATA - Notificar inmediatamente para actualización visual instantánea
    notifyListeners();

    // Actualizar datos desde el API para tener la información completa (en background)
    _actualizarDatosDesdeWebSocket();
  }

  /// Procesa eventos de QR escaneado
  void _procesarQrScanned(WebSocketEvent event) {
    debugPrint(
      '📱 Procesando QR escaneado: Ficha ${event.fichaId}, Aprendiz ${event.aprendizId}',
    );

    // Actualizar datos desde el API
    _actualizarDatosDesdeWebSocket();
  }

  /// Procesa fallback a polling
  void _procesarPollingFallback(WebSocketEvent event) {
    debugPrint('🔄 Procesando fallback a polling');
    
    // Actualizar datos desde API cuando WebSocket falla
    _actualizarDatosDesdePolling();
  }

  /// Procesa validación de sincronización
  void _procesarSyncValidation(WebSocketEvent event) {
    debugPrint('🔄 Procesando validación de sincronización');
    
    // Validar que los datos locales coinciden con el backend
    _validarSincronizacion();
  }

  /// Actualiza los datos cuando se recibe un evento WebSocket
  Future<void> _actualizarDatosDesdeWebSocket() async {
    try {
      if (!_isLoading && !_isUpdating) {
        _setUpdating(true);
        debugPrint('🔄 Actualizando datos desde WebSocket...');

        // Actualizar datos en paralelo con timeout reducido
        await Future.wait([
          _cargarEstadisticas().timeout(const Duration(seconds: 2)),
          _cargarAsistencias().timeout(const Duration(seconds: 2)),
        ]).timeout(const Duration(seconds: 3));

        _lastDataUpdate = DateTime.now();
        _updateCache();
        debugPrint('✅ Datos actualizados desde WebSocket exitosamente');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error al actualizar datos desde WebSocket: $e');
      // No mostrar error al usuario, mantener datos anteriores
    } finally {
      _setUpdating(false);
    }
  }

  /// Actualiza los datos desde polling de fallback
  Future<void> _actualizarDatosDesdePolling() async {
    try {
      if (!_isLoading && !_isUpdating) {
        _setUpdating(true);
        debugPrint('🔄 Actualizando datos desde polling...');

        await _cargarAsistencias().timeout(const Duration(seconds: 3));
        
        _lastDataUpdate = DateTime.now();
        _updateCache();
        debugPrint('✅ Datos actualizados desde polling exitosamente');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error al actualizar datos desde polling: $e');
      // No mostrar error al usuario, mantener datos anteriores
    } finally {
      _setUpdating(false);
    }
  }

  /// Valida sincronización con el backend
  Future<void> _validarSincronizacion() async {
    try {
      debugPrint('🔄 Validando sincronización con backend...');
      
      // Cargar datos frescos del backend
      final nuevasAsistencias = await _apiService.getAsistenciasPorJornada();
      
      // Comparar con datos locales
      if (_hasDataChanged(nuevasAsistencias.asistencias)) {
        debugPrint('🔄 Detectados cambios en sincronización, actualizando...');
        _asistenciasDetalle = nuevasAsistencias.asistencias;
        _lastDataUpdate = DateTime.now();
        _updateCache();
        notifyListeners();
      } else {
        debugPrint('✅ Datos sincronizados correctamente');
      }
    } catch (e) {
      debugPrint('❌ Error en validación de sincronización: $e');
    }
  }

  /// Verifica si los datos han cambiado
  bool _hasDataChanged(List<AsistenciaDetalle> nuevasAsistencias) {
    if (_asistenciasDetalle.length != nuevasAsistencias.length) {
      return true;
    }

    // Comparar IDs de asistencias
    final idsLocales = _asistenciasDetalle.map((a) => a.id).toSet();
    final idsNuevos = nuevasAsistencias.map((a) => a.id).toSet();
    
    return !idsLocales.containsAll(idsNuevos) || !idsNuevos.containsAll(idsLocales);
  }

  /// Carga asistencias desde el API (método público)
  Future<void> cargarAsistencias() async {
    await _cargarAsistencias();
    notifyListeners();
  }

  /// Carga estadísticas desde el API
  Future<void> _cargarEstadisticas() async {
    try {
      _estadisticas = await _apiService.getEstadisticas();
    } catch (e) {
      debugPrint('❌ Error al cargar estadísticas: $e');
      _estadisticas = {};
    }
  }

  /// Carga fichas desde el API
  Future<void> _cargarFichas() async {
    try {
      _fichas = await _apiService.getFichas();
    } catch (e) {
      debugPrint('❌ Error al cargar fichas: $e');
      _fichas = [];
    }
  }

  /// Carga asistencias desde el API
  Future<void> _cargarAsistencias() async {
    try {
      final response = await _apiService.getAsistenciasPorJornada();
      _asistenciasDetalle = response.asistencias;
      debugPrint('✅ Asistencias cargadas: ${_asistenciasDetalle.length} registros');
    } catch (e) {
      debugPrint('❌ Error al cargar asistencias: $e');
      // Mantener datos anteriores en caso de error
    }
  }

  /// Actualiza el cache local
  void _updateCache() {
    _dataCache = {
      'asistencias': _asistenciasDetalle.map((a) => a.toJson()).toList(),
      'estadisticas': _estadisticas,
      'fichas': _fichas,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _lastCacheUpdate = DateTime.now();
  }

  /// Obtiene datos del cache si están disponibles
  Map<String, dynamic>? getCachedData() {
    if (_lastCacheUpdate != null && 
        DateTime.now().difference(_lastCacheUpdate!).inMinutes < 5) {
      return _dataCache;
    }
    return null;
  }

  /// Fuerza actualización manual
  Future<void> forceRefresh() async {
    debugPrint('🔄 Forzando actualización manual...');
    await cargarDatos();
  }

  /// Obtiene estadísticas del servicio robusto
  Map<String, dynamic> getServiceStats() {
    return {
      'webSocketStats': _robustWebSocketService.getStats(),
      'providerStats': {
        'isLoading': _isLoading,
        'isUpdating': _isUpdating,
        'hasError': _hasError,
        'asistenciasCount': _asistenciasDetalle.length,
        'lastDataUpdate': _lastDataUpdate?.toIso8601String(),
        'lastCacheUpdate': _lastCacheUpdate?.toIso8601String(),
      },
    };
  }

  /// Establece estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Establece estado de actualización
  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  /// Establece error
  void _setError(String error) {
    _hasError = true;
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpia error
  void _clearError() {
    _hasError = false;
    _errorMessage = '';
  }

  /// Limpia recursos
  @override
  void dispose() {
    _detenerPollingAutomatico();
    _webSocketStateSubscription?.cancel();
    _webSocketEventSubscription?.cancel();
    _pollingStateSubscription?.cancel();
    _robustWebSocketService.dispose();
    super.dispose();
  }
}
