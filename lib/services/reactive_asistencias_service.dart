import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/asistencia_detalle_model.dart';
import '../models/websocket_event.dart';
import '../services/websocket_pusher_service.dart';

/// Servicio reactivo que maneja asistencias con actualizaciones granulares
/// Permite actualizar solo las cards individuales que han cambiado
class ReactiveAsistenciasService {
  static final ReactiveAsistenciasService _instance =
      ReactiveAsistenciasService._internal();
  factory ReactiveAsistenciasService() => _instance;
  ReactiveAsistenciasService._internal();

  final WebSocketPusherService _webSocketService = WebSocketPusherService();

  // Streams granulares para diferentes tipos de actualizaciones
  final StreamController<List<AsistenciaDetalle>> _asistenciasController =
      StreamController<List<AsistenciaDetalle>>.broadcast();

  final StreamController<AsistenciaDetalle> _asistenciaActualizadaController =
      StreamController<AsistenciaDetalle>.broadcast();

  final StreamController<AsistenciaDetalle> _nuevaAsistenciaController =
      StreamController<AsistenciaDetalle>.broadcast();

  // Streams por jornada para actualizaciones más específicas
  final Map<String, StreamController<List<AsistenciaDetalle>>>
      _jornadaControllers = {};

  // Estado interno
  final Map<String, List<AsistenciaDetalle>> _asistenciasPorJornada = {};
  final Map<int, AsistenciaDetalle> _asistenciasPorId = {};
  StreamSubscription<WebSocketEvent>? _webSocketSubscription;
  bool _isInitialized = false;

  // Getters para streams
  Stream<List<AsistenciaDetalle>> get asistenciasStream =>
      _asistenciasController.stream;
  Stream<AsistenciaDetalle> get asistenciaActualizadaStream =>
      _asistenciaActualizadaController.stream;
  Stream<AsistenciaDetalle> get nuevaAsistenciaStream =>
      _nuevaAsistenciaController.stream;
  Stream<String> get connectionStateStream =>
      _webSocketService.connectionStateStream;

  /// Inicializa el servicio reactivo
  Future<void> initialize(List<AsistenciaDetalle> asistenciasIniciales) async {
    if (_isInitialized) return;

    // Procesar datos iniciales
    _procesarAsistenciasIniciales(asistenciasIniciales);

    // Inicializar y configurar WebSocket
    await _initializeWebSocket();

    _isInitialized = true;
    debugPrint(
        '✅ ReactiveAsistenciasService inicializado con ${asistenciasIniciales.length} asistencias');
  }

  /// Inicializa el WebSocket y configura los listeners
  Future<void> _initializeWebSocket() async {
    try {
      // Inicializar WebSocket
      await _webSocketService.initialize();
      _webSocketService.subscribeToAllChannels();

      // Configurar listener de eventos
      _setupWebSocketListener();

      debugPrint('✅ WebSocket inicializado en ReactiveAsistenciasService');
    } catch (e) {
      debugPrint(
          '❌ Error al inicializar WebSocket en ReactiveAsistenciasService: $e');
    }
  }

  /// Procesa las asistencias iniciales y las organiza por jornada
  void _procesarAsistenciasIniciales(List<AsistenciaDetalle> asistencias) {
    _asistenciasPorJornada.clear();
    _asistenciasPorId.clear();

    for (var asistencia in asistencias) {
      // Organizar por jornada
      if (!_asistenciasPorJornada.containsKey(asistencia.jornada)) {
        _asistenciasPorJornada[asistencia.jornada] = [];
        _jornadaControllers[asistencia.jornada] =
            StreamController<List<AsistenciaDetalle>>.broadcast();
      }
      _asistenciasPorJornada[asistencia.jornada]!.add(asistencia);
      _asistenciasPorId[asistencia.id] = asistencia;
    }

    // Emitir datos iniciales
    _emitirTodosLosDatos();
  }

  /// Configura el listener de eventos WebSocket
  void _setupWebSocketListener() {
    _webSocketSubscription?.cancel();

    _webSocketSubscription = _webSocketService.eventStream.listen(
      _handleWebSocketEvent,
      onError: (error) {
        debugPrint('❌ Error en stream de eventos WebSocket: $error');
      },
    );
  }

  /// Maneja eventos recibidos del WebSocket
  void _handleWebSocketEvent(WebSocketEvent event) async {
    if (!event.isNuevaAsistencia) return;

    debugPrint(
        '🔄 Evento WebSocket recibido: ${event.aprendizNombre} - Ficha ${event.fichaId}');

    try {
      // Simular actualización de datos (en producción esto vendría del API)
      await _simularActualizacionDesdeWebSocket(event);
    } catch (e) {
      debugPrint('❌ Error al procesar evento WebSocket: $e');
    }
  }

  /// Simula la actualización de datos desde WebSocket
  /// En producción, esto haría una llamada al API para obtener los datos actualizados
  Future<void> _simularActualizacionDesdeWebSocket(WebSocketEvent event) async {
    // Simular delay de API
    await Future.delayed(const Duration(milliseconds: 100));

    // Buscar si ya existe una asistencia para este aprendiz
    final asistenciaExistente = _asistenciasPorId.values
        .where((a) => a.aprendiz
            .toLowerCase()
            .contains((event.aprendizNombre ?? '').toLowerCase()))
        .firstOrNull;

    if (asistenciaExistente != null) {
      // Actualizar asistencia existente (ej: salida)
      await _actualizarAsistenciaExistente(asistenciaExistente, event);
    } else {
      // Crear nueva asistencia (entrada)
      await _crearNuevaAsistencia(event);
    }
  }

  /// Actualiza una asistencia existente (ej: cuando se registra la salida)
  Future<void> _actualizarAsistenciaExistente(
      AsistenciaDetalle asistencia, WebSocketEvent event) async {
    // Crear asistencia actualizada
    final asistenciaActualizada = AsistenciaDetalle(
      id: asistencia.id,
      aprendiz: asistencia.aprendiz,
      numeroDocumento: asistencia.numeroDocumento,
      horaIngreso: asistencia.horaIngreso,
      horaSalida: event.estadoAsistencia == 'salida'
          ? _getCurrentTime()
          : asistencia.horaSalida,
      ficha: asistencia.ficha,
      jornada: asistencia.jornada,
      jornadaId: asistencia.jornadaId,
      fecha: asistencia.fecha,
      estado:
          event.estadoAsistencia == 'salida' ? 'completa' : asistencia.estado,
    );

    // Actualizar en memoria
    _asistenciasPorId[asistencia.id] = asistenciaActualizada;
    _actualizarEnJornada(asistenciaActualizada);

    // Emitir actualización específica
    _asistenciaActualizadaController.add(asistenciaActualizada);

    debugPrint(
        '✅ Asistencia actualizada: ${asistenciaActualizada.aprendiz} - ${asistenciaActualizada.estado}');
  }

  /// Crea una nueva asistencia (ej: cuando se registra la entrada)
  Future<void> _crearNuevaAsistencia(WebSocketEvent event) async {
    // Generar ID único
    final nuevoId = DateTime.now().millisecondsSinceEpoch;

    // Crear nueva asistencia
    final nuevaAsistencia = AsistenciaDetalle(
      id: nuevoId,
      aprendiz: event.aprendizNombre ?? 'Aprendiz Desconocido',
      numeroDocumento: 'N/A',
      horaIngreso: _getCurrentTime(),
      horaSalida: null,
      ficha: event.fichaId ?? 'N/A',
      jornada: event.jornada ?? 'MAÑANA',
      jornadaId: 1, // Valor por defecto
      fecha: _getCurrentDate(),
      estado: 'en_curso',
    );

    // Agregar a memoria
    _asistenciasPorId[nuevoId] = nuevaAsistencia;

    // Agregar a la jornada correspondiente
    if (!_asistenciasPorJornada.containsKey(nuevaAsistencia.jornada)) {
      _asistenciasPorJornada[nuevaAsistencia.jornada] = [];
      _jornadaControllers[nuevaAsistencia.jornada] =
          StreamController<List<AsistenciaDetalle>>.broadcast();
    }
    _asistenciasPorJornada[nuevaAsistencia.jornada]!.add(nuevaAsistencia);

    // Emitir nueva asistencia
    _nuevaAsistenciaController.add(nuevaAsistencia);

    debugPrint(
        '✅ Nueva asistencia creada: ${nuevaAsistencia.aprendiz} - ${nuevaAsistencia.ficha}');
  }

  /// Actualiza una asistencia en su jornada correspondiente
  void _actualizarEnJornada(AsistenciaDetalle asistencia) {
    final jornada = asistencia.jornada;
    if (_asistenciasPorJornada.containsKey(jornada)) {
      final index = _asistenciasPorJornada[jornada]!
          .indexWhere((a) => a.id == asistencia.id);
      if (index != -1) {
        _asistenciasPorJornada[jornada]![index] = asistencia;
      }
    }
  }

  /// Obtiene el stream de una jornada específica
  Stream<List<AsistenciaDetalle>> getJornadaStream(String jornada) {
    if (!_jornadaControllers.containsKey(jornada)) {
      _jornadaControllers[jornada] =
          StreamController<List<AsistenciaDetalle>>.broadcast();
    }
    return _jornadaControllers[jornada]!.stream;
  }

  /// Obtiene las asistencias de una jornada específica
  List<AsistenciaDetalle> getAsistenciasJornada(String jornada) {
    return _asistenciasPorJornada[jornada] ?? [];
  }

  /// Obtiene todas las asistencias
  List<AsistenciaDetalle> get todasLasAsistencias =>
      _asistenciasPorId.values.toList();

  /// Obtiene las jornadas disponibles
  List<String> get jornadasDisponibles => _asistenciasPorJornada.keys.toList();

  /// Emite todos los datos actualizados
  void _emitirTodosLosDatos() {
    _asistenciasController.add(todasLasAsistencias);

    // Emitir datos por jornada
    _asistenciasPorJornada.forEach((jornada, asistencias) {
      _jornadaControllers[jornada]?.add(asistencias);
    });
  }

  /// Actualiza manualmente los datos (para sincronización con API)
  void actualizarDatos(List<AsistenciaDetalle> nuevasAsistencias) {
    _procesarAsistenciasIniciales(nuevasAsistencias);
  }

  /// Obtiene el tiempo actual formateado
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// Obtiene la fecha actual formateada
  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Libera los recursos del servicio
  void dispose() {
    _webSocketSubscription?.cancel();
    _asistenciasController.close();
    _asistenciaActualizadaController.close();
    _nuevaAsistenciaController.close();

    _jornadaControllers.values.forEach((controller) => controller.close());
    _jornadaControllers.clear();

    _isInitialized = false;
  }
}
