import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';

import '../models/asistencia_model.dart';
import '../models/asistencia_detalle_model.dart';
import '../models/estadisticas_model.dart';
import '../models/ficha_model.dart';
import '../models/websocket_event.dart';
import '../services/api_service.dart';
import '../services/websocket_pusher_service.dart';
import '../utils/websocket_constants.dart';

class AsistenciaProvider with ChangeNotifier {
  final ApiService _apiService;
  final dynamic _webSocketService;

  // Estado de carga
  bool _isLoading = false;
  bool _isUpdating = false;
  String _errorMessage = '';

  // Datos
  Map<String, EstadisticasJornada> _estadisticas = {};
  List<Asistencia> _asistencias = [];
  List<AsistenciaDetalle> _asistenciasDetalle = [];
  List<FichaModel> _fichas = [];
  String _jornadaActual = '';
  Timer? _refreshTimer;

  // Últimas asistencias recibidas por WebSocket (para mostrar en tiempo real)
  final List<WebSocketEvent> _ultimasAsistenciasWS = [];

  // WebSocket
  String _webSocketState = WebSocketConstants.estadoDesconectado;
  StreamSubscription? _webSocketEventSubscription;
  StreamSubscription? _webSocketStateSubscription;

  // Getters
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  Map<String, EstadisticasJornada> get estadisticas => _estadisticas;
  List<Asistencia> get asistencias => _asistencias;
  List<AsistenciaDetalle> get asistenciasDetalle => _asistenciasDetalle;
  List<FichaModel> get fichas => _fichas;
  String get jornadaActual => _jornadaActual;
  ApiService get apiService => _apiService;
  dynamic get webSocketService => _webSocketService;
  String get webSocketState => _webSocketState;
  bool get isWebSocketConnected =>
      _webSocketState == WebSocketConstants.estadoConectado;

  /// Últimas 10 asistencias recibidas por WebSocket
  List<WebSocketEvent> get ultimasAsistenciasWebSocket =>
      List.unmodifiable(_ultimasAsistenciasWS);

  /// Devuelve las fichas de la jornada actual
  List<FichaModel> get fichasJornadaActual {
    if (_jornadaActual.isEmpty) return [];
    return _fichas
        .where((f) =>
            _normalizar(f.jornadaFormacion.jornada) ==
            _normalizar(_jornadaActual))
        .toList();
  }

  /// Devuelve las asistencias de las fichas de la jornada actual
  List<Asistencia> get asistenciasJornadaActual {
    final fichasIds =
        fichasJornadaActual.map((f) => f.numeroFicha.toString()).toSet();
    final jornadaActualNorm = _normalizar(_jornadaActual);
    return _asistencias
        .where((a) =>
            fichasIds.contains(a.ficha) &&
            _normalizar(a.jornada) == jornadaActualNorm)
        .toList();
  }

  /// Constructor
  AsistenciaProvider({
    required ApiService apiService,
    dynamic webSocketService,
  })  : _apiService = apiService,
        _webSocketService = webSocketService ?? WebSocketPusherService() {
    _init();
  }

  /// Inicialización del provider
  Future<void> _init() async {
    await cargarDatos();
    _configurarActualizacionAutomatica();
    _configurarWebSocket();
  }

  /// Carga todos los datos iniciales
  Future<void> cargarDatos() async {
    _setLoading(true);
    _clearError();
    try {
      _jornadaActual = JornadaConstants.getJornadaString(
          JornadaConstants.getJornadaActual());

      await _cargarEstadisticas();
      await _cargarFichas();
      await _cargarAsistencias();

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error general al cargar los datos: $e');
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
    _setUpdating(true);
    try {
      final nuevaJornada = JornadaConstants.getJornadaActual();
      final nuevaJornadaString =
          JornadaConstants.getJornadaString(nuevaJornada);

      // Actualizar jornada si cambió
      if (nuevaJornadaString != _jornadaActual) {
        _jornadaActual = nuevaJornadaString;
      }

      // Cargar datos en paralelo para mejor rendimiento
      await Future.wait([
        _cargarEstadisticas(),
        _cargarFichas(),
        _cargarAsistencias(),
      ]);

      // Notificar a los listeners siempre, incluso si hay errores parciales
      notifyListeners();
    } catch (e) {
      debugPrint('Error al actualizar datos: $e');
      // Notificar incluso con errores para que la UI pueda mostrar el estado
      notifyListeners();
    } finally {
      _setUpdating(false);
    }
  }

  /// Carga estadísticas desde el API
  Future<void> _cargarEstadisticas() async {
    try {
      _estadisticas = await _apiService.getEstadisticas();
    } catch (e) {
      debugPrint('Error al cargar estadísticas: $e');
      _estadisticas = {};
    }
  }

  /// Carga fichas desde el API
  Future<void> _cargarFichas() async {
    try {
      _fichas = await _apiService.getFichas();
    } catch (e) {
      debugPrint('Error al cargar fichas: $e');
      _fichas = [];
    }
  }

  /// Carga asistencias desde el API
  /// Obtiene todas las jornadas del día actual
  Future<void> _cargarAsistencias() async {
    try {
      // Obtener TODAS las asistencias del día actual (sin filtrar por jornada)
      // El backend devolverá todas las jornadas agrupadas en "por_jornada"
      final response = await _apiService.getAsistenciasPorJornada(
        // No enviar jornadaId para obtener todas las jornadas
        jornadaId: null,
        // Usar fecha actual automáticamente
        fecha: DateTime.now(),
      );

      _asistenciasDetalle = response.asistencias;

      debugPrint('✅ Asistencias cargadas: ${_asistenciasDetalle.length}');
      debugPrint('📊 Jornadas: ${response.porJornada.keys.toList()}');

      // Mostrar detalle por jornada
      response.porJornada.forEach((jornada, asistencias) {
        debugPrint('   - $jornada: ${asistencias.length} asistencias');
      });
    } catch (e) {
      debugPrint('❌ Error al cargar asistencias: $e');
      _asistencias = [];
      _asistenciasDetalle = [];
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
    return s
        .trim()
        .toLowerCase()
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

  void _setUpdating(bool value) {
    _isUpdating = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = '$_errorMessage$message\n';
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }

  // --- Métodos WebSocket ---

  /// Configura el WebSocket y sus suscripciones
  void _configurarWebSocket() {
    // Suscribirse a cambios de estado del WebSocket
    _webSocketStateSubscription =
        _webSocketService.connectionStateStream.listen(
      (state) {
        _webSocketState = state;
        notifyListeners();
      },
    );

    // Suscribirse a eventos del WebSocket
    _webSocketEventSubscription = _webSocketService.eventStream.listen(
      _manejarEventoWebSocket,
      onError: (error) {
        debugPrint('❌ Error en stream de eventos WebSocket: $error');
      },
    );

    // Inicializar WebSocket
    _inicializarWebSocket();
  }

  /// Inicializa la conexión WebSocket
  Future<void> _inicializarWebSocket() async {
    try {
      await _webSocketService.initialize();
      _webSocketService.subscribeToAllChannels();
      debugPrint('✅ WebSocket configurado y suscrito a canales');
    } catch (e) {
      debugPrint('❌ Error al inicializar WebSocket: $e');
      _setError('Error al conectar WebSocket: $e');
    }
  }

  /// Maneja eventos recibidos del WebSocket
  void _manejarEventoWebSocket(WebSocketEvent event) {
    try {
      if (event.isNuevaAsistencia) {
        _procesarNuevaAsistencia(event);
      } else if (event.isQrScanned) {
        _procesarQrScanned(event);
      }

      // Notificar a los listeners sobre el cambio
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al procesar evento WebSocket: $e');
    }
  }

  /// Procesa eventos de nueva asistencia registrada
  void _procesarNuevaAsistencia(WebSocketEvent event) {
    debugPrint('📝 Nueva asistencia - ID: ${event.asistenciaId}, '
        'Aprendiz: ${event.aprendizNombre}, '
        'Estado: ${event.estadoAsistencia}, '
        'Ficha: ${event.fichaId}, '
        'Jornada: ${event.jornada}');

    // Agregar a la lista de últimas asistencias
    _ultimasAsistenciasWS.insert(0, event);

    // Mantener solo las últimas 10
    if (_ultimasAsistenciasWS.length > 10) {
      _ultimasAsistenciasWS.removeRange(10, _ultimasAsistenciasWS.length);
    }

    // Actualizar datos desde el API para tener la información completa
    _actualizarDatosDesdeWebSocket();
  }

  /// Procesa eventos de QR escaneado
  void _procesarQrScanned(WebSocketEvent event) {
    debugPrint(
        '📱 Procesando QR escaneado: Ficha ${event.fichaId}, Aprendiz ${event.aprendizId}');

    // Aquí podrías procesar el escaneo del QR
    // Por ejemplo, actualizar estadísticas en tiempo real
    _actualizarDatosDesdeWebSocket();
  }

  /// Actualiza los datos cuando se recibe un evento WebSocket
  Future<void> _actualizarDatosDesdeWebSocket() async {
    try {
      // Solo actualizar si no estamos en proceso de carga
      if (!_isLoading && !_isUpdating) {
        _setUpdating(true);

        // Actualizar datos en paralelo
        await Future.wait([
          _cargarEstadisticas(),
          _cargarAsistencias(),
        ]);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error al actualizar datos desde WebSocket: $e');
    } finally {
      _setUpdating(false);
    }
  }

  /// Conecta manualmente el WebSocket
  Future<void> conectarWebSocket() async {
    await _webSocketService.connect();
  }

  /// Desconecta manualmente el WebSocket
  Future<void> desconectarWebSocket() async {
    await _webSocketService.disconnect();
  }

  /// Limpia los recursos al destruir el provider
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _webSocketEventSubscription?.cancel();
    _webSocketStateSubscription?.cancel();
    super.dispose();
  }
}
