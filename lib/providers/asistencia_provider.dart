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
import '../services/test_endpoint_service.dart';
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
  List<Map<String, dynamic>> _fichas = [];
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
  List<Map<String, dynamic>> get fichas => _fichas;
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
  List<Map<String, dynamic>> get fichasJornadaActual {
    if (_jornadaActual.isEmpty) return [];

    // Obtener el ID de jornada actual (1=MAÑANA, 2=TARDE, 3=NOCHE)
    final hora = DateTime.now().hour;
    final jornadaIdActual = hora >= 6 && hora < 12
        ? 1
        : hora >= 12 && hora < 18
            ? 2
            : hora >= 18 && hora < 22
                ? 3
                : 0;

    debugPrint(
        '🔍 Filtrando fichas para jornada ID: $jornadaIdActual (${_jornadaActual})');

    final fichasFiltradas = _fichas.where((f) {
      final fichaJornadaId = f['jornada_id'] ?? 0;
      return fichaJornadaId == jornadaIdActual;
    }).toList();

    debugPrint(
        '✅ Fichas encontradas para jornada $jornadaIdActual: ${fichasFiltradas.length}');
    for (var ficha in fichasFiltradas) {
      debugPrint(
          '   - Ficha ${ficha['ficha']} (ID: ${ficha['id']}, Jornada: ${ficha['jornada_id']})');
    }

    return fichasFiltradas;
  }

  /// Devuelve las asistencias de las fichas de la jornada actual
  List<Asistencia> get asistenciasJornadaActual {
    final fichasIds =
        fichasJornadaActual.map((f) => f['ficha'].toString()).toSet();
    final jornadaActualNorm = _normalizar(_jornadaActual);
    return _asistencias
        .where(
          (a) =>
              fichasIds.contains(a.ficha) &&
              _normalizar(a.jornada) == jornadaActualNorm,
        )
        .toList();
  }

  /// Constructor
  AsistenciaProvider({required ApiService apiService, dynamic webSocketService})
      : _apiService = apiService,
        _webSocketService = webSocketService ?? WebSocketPusherService() {
    _init();
  }

  /// Inicialización del provider
  Future<void> _init() async {
    await cargarDatos();
    // Comentado: Se reemplaza por eventos WebSocket en tiempo real
    // _configurarActualizacionAutomatica();
    _configurarWebSocket();
  }

  /// Carga todos los datos iniciales
  Future<void> cargarDatos() async {
    _setLoading(true);
    _clearError();
    try {
      _jornadaActual = JornadaConstants.getJornadaString(
        JornadaConstants.getJornadaActual(),
      );

      await _cargarEstadisticas();
      await _cargarFichas();
      await cargarAsistencias();

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error general al cargar los datos: $e');
      _setError('Error general al cargar los datos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Configura la actualización automática periódica
  /// COMENTADO: Se reemplaza por eventos WebSocket en tiempo real
  /*
  void _configurarActualizacionAutomatica() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: ApiConstants.refreshTime),
      (timer) => _actualizarDatos(),
    );
  }
  */

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

  /// Carga asistencias desde el API (optimizado para máximo 2s)
  /// Obtiene todas las jornadas del día actual
  Future<void> cargarAsistencias() async {
    try {
      // Prueba del endpoint antes de la llamada real
      debugPrint('🧪 Ejecutando prueba del endpoint...');
      await TestEndpointService.testAsistenciasEndpoint();

      // Obtener TODAS las asistencias del día actual (sin filtrar por jornada)
      // El backend devolverá todas las jornadas agrupadas en "por_jornada"
      final response = await _apiService
          .getAsistenciasPorJornada(
            // No enviar jornadaId para obtener todas las jornadas
            jornadaId: null,
            // Usar fecha actual automáticamente
            fecha: DateTime.now(),
          )
          .timeout(const Duration(seconds: 2));

      _asistenciasDetalle = response.asistencias;

      debugPrint('✅ Asistencias cargadas: ${_asistenciasDetalle.length}');
      debugPrint(
          '📊 Total asistencias del response: ${response.totalAsistencias}');
      debugPrint('📊 Jornadas: ${response.porJornada.keys.toList()}');

      // Debug detallado de cada asistencia
      for (int i = 0; i < _asistenciasDetalle.length; i++) {
        final asistencia = _asistenciasDetalle[i];
        debugPrint(
            '   Asistencia $i: ${asistencia.aprendiz} - Ficha: ${asistencia.ficha} - Estado: ${asistencia.estado}');
      }

      // Mostrar detalle por jornada
      response.porJornada.forEach((jornada, asistencias) {
        debugPrint('   - $jornada: ${asistencias.length} asistencias');
        for (var asistencia in asistencias) {
          debugPrint(
              '     * ${asistencia.aprendiz} - Ficha: ${asistencia.ficha}');
        }
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
        _webSocketService.connectionStateStream.listen((state) {
      _webSocketState = state;
      notifyListeners();
    });

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

  /// Maneja eventos recibidos del WebSocket (optimizado para respuesta inmediata)
  void _manejarEventoWebSocket(WebSocketEvent event) {
    try {
      debugPrint('📨 Procesando evento WebSocket: ${event.event}');

      if (event.isNuevaAsistencia) {
        _procesarNuevaAsistencia(event);
      } else if (event.isQrScanned) {
        _procesarQrScanned(event);
      }

      // Los métodos individuales ya manejan notifyListeners()
      // No es necesario llamarlo aquí para evitar duplicaciones
    } catch (e) {
      debugPrint('❌ Error al procesar evento WebSocket: $e');
    }
  }

  /// Procesa eventos de nueva asistencia registrada (optimizado para respuesta inmediata)
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

    // Mantener solo las últimas 10
    if (_ultimasAsistenciasWS.length > 10) {
      _ultimasAsistenciasWS.removeRange(10, _ultimasAsistenciasWS.length);
    }

    // Notificar inmediatamente para actualización visual instantánea
    notifyListeners();

    // Actualizar datos desde el API para tener la información completa (en background)
    _actualizarDatosDesdeWebSocket();
  }

  /// Procesa eventos de QR escaneado
  void _procesarQrScanned(WebSocketEvent event) {
    debugPrint(
      '📱 Procesando QR escaneado: Ficha ${event.fichaId}, Aprendiz ${event.aprendizId}',
    );

    // Aquí podrías procesar el escaneo del QR
    // Por ejemplo, actualizar estadísticas en tiempo real
    _actualizarDatosDesdeWebSocket();
  }

  /// Actualiza los datos cuando se recibe un evento WebSocket (optimizado para máximo 1s)
  Future<void> _actualizarDatosDesdeWebSocket() async {
    try {
      // Solo actualizar si no estamos en proceso de carga
      if (!_isLoading && !_isUpdating) {
        _setUpdating(true);

        debugPrint('🔄 Actualizando datos desde WebSocket...');

        // Actualizar datos en paralelo con timeout reducido a 1 segundo
        await Future.wait([
          _cargarEstadisticas().timeout(const Duration(seconds: 1)),
          cargarAsistencias().timeout(const Duration(seconds: 1)),
        ]).timeout(const Duration(seconds: 1));

        debugPrint('✅ Datos actualizados desde WebSocket exitosamente');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error al actualizar datos desde WebSocket: $e');
      // Intentar actualización de respaldo más rápida
      await _actualizacionRapidaRespaldo();
    } finally {
      _setUpdating(false);
    }
  }

  /// Actualización rápida de respaldo cuando falla la principal
  Future<void> _actualizacionRapidaRespaldo() async {
    try {
      debugPrint('🔄 Ejecutando actualización rápida de respaldo...');

      // Solo cargar asistencias (más crítico) con timeout muy corto
      await cargarAsistencias().timeout(const Duration(milliseconds: 500));

      debugPrint('✅ Actualización rápida de respaldo completada');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error en actualización rápida de respaldo: $e');
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
