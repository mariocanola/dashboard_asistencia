import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/asistencia_detalle_model.dart';
import '../models/websocket_event.dart';
import '../services/hybrid_realtime_service.dart';
import '../services/api_service.dart';

/// Provider que usa el servicio híbrido WebSocket + REST
/// Implementa exactamente la lógica sugerida:
/// - WebSocket activo → eventos en tiempo real
/// - WebSocket falla → polling rápido cada 2s
/// - Al reconectar → se detiene polling y vuelve al flujo normal
class HybridAsistenciaProvider extends ChangeNotifier {
  final ApiService _apiService;
  final HybridRealtimeService _hybridService = HybridRealtimeService();

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

  // Estado de conexión híbrida
  bool _isWebSocketActive = false;
  bool _isPollingActive = false;
  DateTime? _lastDataUpdate;
  DateTime? _lastEventReceived;
  Timer? _inactivityCheckTimer;

  // Subscripciones
  StreamSubscription<bool>? _connectionStateSubscription;
  StreamSubscription<List<AsistenciaDetalle>>? _dataSubscription;
  StreamSubscription<WebSocketEvent>? _eventSubscription;

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

  bool get isWebSocketActive => _isWebSocketActive;
  bool get isPollingActive => _isPollingActive;
  DateTime? get lastDataUpdate => _lastDataUpdate;

  // Propiedades adicionales para compatibilidad con el dashboard
  double? get kpiAsistenciaPorcentaje {
    // Si no hay fichas o asistencias, no se puede calcular
    if (_fichas.isEmpty) return null;

    // Calcular total de aprendices según las fichas de la jornada actual
    final fichasJornada = fichasJornadaActual;
    final totalAprendicesJornada = fichasJornada.fold<int>(
      0,
      (sum, ficha) {
        final total = ficha['total_aprendices'] ?? 0;
        return sum +
            (total is int ? total : int.tryParse(total.toString()) ?? 0);
      },
    );

    if (totalAprendicesJornada == 0) return 0.0;

    // Calcular presentes (sin duplicar aprendices)
    final presentesUnicos = _asistenciasDetalle
        .where((a) => a.estado == 'en_curso' || a.estado == 'completa')
        .map((a) => a.aprendiz)
        .toSet()
        .length;

    final porcentaje = (presentesUnicos / totalAprendicesJornada) * 100;

    debugPrint(
        '📈 KPI Preciso - ${presentesUnicos}/${totalAprendicesJornada} aprendices presentes (${porcentaje.toStringAsFixed(2)}%)');

    return porcentaje;
  }

  /// Total de fichas en la jornada actual
  int get totalFichas {
    return fichasJornadaActual.length;
  }

  /// Total de aprendices presentes (con estado 'en_curso' o 'completa')
  int get presentes {
    if (_asistenciasDetalle.isEmpty) return 0;
    return _asistenciasDetalle
        .where((a) => a.estado == 'en_curso' || a.estado == 'completa')
        .map((a) => a.aprendiz)
        .toSet()
        .length;
  }

  /// Total de aprendices ausentes = total esperados - presentes
  int get ausentes {
    if (_fichas.isEmpty) return 0;

    int totalAprendicesJornada = 0;
    for (var ficha in fichasJornadaActual) {
      final total = ficha['total_aprendices'] ?? 0;
      totalAprendicesJornada +=
          total is int ? total : int.tryParse(total.toString()) ?? 0;
    }

    final totalAusentes = totalAprendicesJornada - presentes;
    return totalAusentes.clamp(0, totalAprendicesJornada);
  }

  /// Total de aprendices esperados (suma de todas las fichas)
  int get totalAprendices {
    if (_fichas.isEmpty) return 0;

    int total = 0;
    for (var ficha in fichasJornadaActual) {
      final valor = ficha['total_aprendices'] ?? 0;
      total += valor is int ? valor : int.tryParse(valor.toString()) ?? 0;
    }
    return total;
  }

  HybridAsistenciaProvider({required ApiService apiService})
      : _apiService = apiService {
    _init();
  }

  /// Inicialización del provider híbrido
  Future<void> _init() async {
    await _cargarDatosIniciales();
    _configurarServicioHibrido();
  }

  /// Carga datos iniciales desde API
  Future<void> _cargarDatosIniciales() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔄 Cargando datos iniciales...');

      // Determinar jornada actual
      _jornadaActual = _determinarJornadaActual();

      // Cargar datos en paralelo
      await Future.wait([
        _cargarEstadisticas(),
        _cargarFichas(),
        _cargarAsistencias(),
      ]);

      _lastDataUpdate = DateTime.now();
      notifyListeners();

      debugPrint('✅ Datos iniciales cargados exitosamente');
    } catch (e) {
      debugPrint('❌ Error al cargar datos iniciales: $e');
      _setError('Error al cargar datos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Configura el servicio híbrido
  void _configurarServicioHibrido() {
    // Suscribirse a cambios de estado de conexión
    _connectionStateSubscription =
        _hybridService.connectionStateStream.listen((isWebSocketActive) {
      _isWebSocketActive = isWebSocketActive;
      _isPollingActive = !isWebSocketActive;

      debugPrint(
          '🔄 Estado conexión: ${isWebSocketActive ? "WebSocket Activo ✅" : "Usando Polling ⏳"}');
      notifyListeners();
    });

    // Suscribirse a actualizaciones de datos
    _dataSubscription = _hybridService.dataStream.listen((nuevasAsistencias) {
      _asistenciasDetalle = nuevasAsistencias;
      _lastDataUpdate = DateTime.now();
      _lastEventReceived = DateTime.now();
      debugPrint(
          '📊 Datos actualizados: ${nuevasAsistencias.length} asistencias');
      notifyListeners();
    });

    // Suscribirse a eventos WebSocket
    _eventSubscription = _hybridService.eventStream.listen((event) {
      _lastEventReceived = DateTime.now();
      debugPrint(
          '⚡ EVENTO REAL RECIBIDO: ${event.event} en canal ${event.channel}');
      _procesarEventoWebSocket(event);
    });

    // Iniciar monitor adicional de inactividad en el provider
    _startProviderInactivityCheck();

    // Inicializar servicio híbrido
    _hybridService.initialize();
    debugPrint('✅ Servicio híbrido configurado');
  }

  /// Monitor de inactividad a nivel de provider (adicional al del servicio)
  void _startProviderInactivityCheck() {
    _inactivityCheckTimer?.cancel();

    _inactivityCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final now = DateTime.now();

      if (_isWebSocketActive && _lastEventReceived != null) {
        final timeSinceLastEvent = now.difference(_lastEventReceived!);

        if (timeSinceLastEvent.inSeconds > 10) {
          debugPrint(
              '⚠️ Provider: No se han recibido eventos en ${timeSinceLastEvent.inSeconds}s');
          debugPrint('🔄 Provider: Forzando actualización por inactividad...');

          // Forzar una actualización desde la API
          _actualizarDatosDesdeAPI();
        }
      }
    });

    debugPrint('👁️ Monitor de inactividad del provider iniciado');
  }

  /// Procesa eventos del WebSocket
  void _procesarEventoWebSocket(WebSocketEvent event) {
    debugPrint('📨 Procesando evento WebSocket: ${event.event}');
    debugPrint('   Aprendiz: ${event.aprendizNombre ?? "N/A"}');
    debugPrint('   Ficha: ${event.fichaId ?? "N/A"}');
    debugPrint('   Estado: ${event.estadoAsistencia ?? "N/A"}');

    _lastEventReceived = DateTime.now();

    if (event.isNuevaAsistencia) {
      _procesarNuevaAsistencia(event);
    } else if (event.isQrScanned) {
      _procesarQrScanned(event);
    }
  }

  /// Procesa nueva asistencia registrada con actualización ultra-rápida
  void _procesarNuevaAsistencia(WebSocketEvent event) {
    debugPrint(
      '📝 Nueva asistencia recibida - ID: ${event.asistenciaId}, '
      'Aprendiz: ${event.aprendizNombre}, '
      'Estado: ${event.estadoAsistencia}, '
      'Ficha: ${event.fichaId}, '
      'Jornada: ${event.jornada}',
    );

    // Crear AsistenciaDetalle temporal para actualización inmediata (< 1 segundo)
    final tempAsistencia = AsistenciaDetalle(
      id: event.asistenciaId ?? 0,
      aprendiz: event.aprendizNombre ?? 'Desconocido',
      numeroDocumento: '',
      horaIngreso:
          event.timestamp.toLocal().toString().split(' ')[1].substring(0, 8),
      ficha: event.fichaId ?? 'Desconocida',
      jornada: event.jornada ?? 'Desconocida',
      jornadaId: 0,
      fecha: event.timestamp.toLocal().toString().split(' ')[0],
      estado: event.estadoAsistencia ?? 'en_curso',
    );

    // Actualización inmediata sin duplicados
    _actualizarAsistenciaInmediata(tempAsistencia);
    _ultimasAsistenciasWS.insert(0, event);

    // Limitar historial a 10 eventos
    if (_ultimasAsistenciasWS.length > 10) {
      _ultimasAsistenciasWS.removeRange(10, _ultimasAsistenciasWS.length);
    }

    _lastDataUpdate = DateTime.now();
    notifyListeners(); // Actualización inmediata de la UI (< 1 segundo)

    debugPrint('✅ Asistencia agregada inmediatamente a la UI');
  }

  /// Actualiza asistencia inmediatamente sin duplicados
  void _actualizarAsistenciaInmediata(AsistenciaDetalle nuevaAsistencia) {
    // Buscar si ya existe una asistencia del mismo aprendiz en la misma fecha
    final indexExistente = _asistenciasDetalle.indexWhere((a) =>
        a.aprendiz == nuevaAsistencia.aprendiz &&
        a.fecha == nuevaAsistencia.fecha &&
        a.ficha == nuevaAsistencia.ficha);

    if (indexExistente != -1) {
      // Actualizar asistencia existente
      _asistenciasDetalle[indexExistente] = nuevaAsistencia;
      debugPrint('🔄 Asistencia actualizada para ${nuevaAsistencia.aprendiz}');
    } else {
      // Agregar nueva asistencia al inicio
      _asistenciasDetalle.insert(0, nuevaAsistencia);
      debugPrint(
          '➕ Nueva asistencia agregada para ${nuevaAsistencia.aprendiz}');
    }
  }

  /// Procesa eventos de QR escaneado
  void _procesarQrScanned(WebSocketEvent event) {
    debugPrint(
      '📱 Procesando QR escaneado: Ficha ${event.fichaId}, Aprendiz ${event.aprendizId}',
    );

    // Actualizar datos para reflejar posibles cambios
    _actualizarDatosDesdeAPI();
  }

  /// Actualiza datos desde API (usado por polling y eventos) - Optimizado para velocidad
  Future<void> _actualizarDatosDesdeAPI() async {
    try {
      if (!_isUpdating) {
        _setUpdating(true);
        debugPrint('🔄 Actualizando datos desde API...');

        // Solo actualizar asistencias para mantener velocidad
        await _cargarAsistencias();

        _lastDataUpdate = DateTime.now();
        debugPrint('✅ Datos actualizados desde API exitosamente');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error al actualizar datos desde API: $e');
      _setError('Error al actualizar datos: $e');
    } finally {
      _setUpdating(false);
    }
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

  /// Obtiene el ID de jornada correspondiente a la jornada actual
  int get jornadaIdActual {
    final hora = DateTime.now().hour;
    if (hora >= 6 && hora < 12) {
      return 1; // MAÑANA
    } else if (hora >= 12 && hora < 18) {
      return 2; // TARDE
    } else if (hora >= 18 && hora < 22) {
      return 3; // NOCHE
    } else {
      return 0; // Fuera de jornada
    }
  }

  /// Devuelve las fichas filtradas por la jornada actual
  List<dynamic> get fichasJornadaActual {
    if (_fichas.isEmpty) return [];

    final jornadaId = jornadaIdActual;
    debugPrint(
        '🔍 Filtrando fichas para jornada ID: $jornadaId ($_jornadaActual)');

    // Debug: Mostrar todas las fichas disponibles
    debugPrint('📋 Todas las fichas disponibles:');
    for (var ficha in _fichas) {
      debugPrint(
          '   - Ficha ${ficha['ficha']} (ID: ${ficha['id']}, Jornada: ${ficha['jornada_id']})');
    }

    final fichasFiltradas = _fichas.where((ficha) {
      final fichaJornadaId = ficha['jornada_id'] ?? 0;
      return fichaJornadaId == jornadaId;
    }).toList();

    debugPrint(
        '✅ Fichas encontradas para jornada $jornadaId: ${fichasFiltradas.length}');
    for (var ficha in fichasFiltradas) {
      debugPrint(
          '   - Ficha ${ficha['ficha']} (ID: ${ficha['id']}, Jornada: ${ficha['jornada_id']})');
    }

    return fichasFiltradas;
  }

  /// Carga todos los datos (método público)
  Future<void> cargarDatos() async {
    await _cargarDatosIniciales();
  }

  /// Carga asistencias desde el API (método público)
  Future<void> cargarAsistencias() async {
    await _cargarAsistencias();
    notifyListeners();
  }

  /// Carga asistencias desde el API
  Future<void> _cargarAsistencias() async {
    try {
      final response = await _apiService.getAsistenciasPorJornada();
      _asistenciasDetalle = response.asistencias;
      debugPrint(
          '✅ Asistencias cargadas: ${_asistenciasDetalle.length} registros');
    } catch (e) {
      debugPrint('❌ Error al cargar asistencias: $e');
      // Mantener datos anteriores en caso de error
    }
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

  /// Carga fichas desde el API (con total de aprendices por ficha)
  Future<void> _cargarFichas() async {
    try {
      debugPrint('🔍 Cargando fichas con aprendices desde API...');
      _fichas = await _apiService.getFichasConAprendices();
      debugPrint('✅ Fichas cargadas: ${_fichas.length} fichas con aprendices');
    } catch (e) {
      debugPrint('❌ Error al cargar fichas con aprendices: $e');
      _fichas = [];
    }
  }

  /// Reconecta el servicio híbrido
  Future<void> reconnect() async {
    debugPrint('🔄 Reconectando servicio híbrido...');
    await _hybridService.reconnect();
  }

  /// Obtiene estadísticas del servicio
  Map<String, dynamic> getServiceStats() {
    return {
      'isWebSocketActive': _isWebSocketActive,
      'isPollingActive': _isPollingActive,
      'lastUpdate': _lastDataUpdate?.toIso8601String(),
      'connectionMode':
          _isWebSocketActive ? 'WebSocket Activo ✅' : 'Usando Polling ⏳',
    };
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
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
  }

  @override
  void dispose() {
    _connectionStateSubscription?.cancel();
    _dataSubscription?.cancel();
    _eventSubscription?.cancel();
    _inactivityCheckTimer?.cancel();
    _hybridService.dispose();
    super.dispose();
  }
}
