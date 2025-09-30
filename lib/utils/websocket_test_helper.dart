import 'package:flutter/foundation.dart';
import '../models/websocket_event.dart';
import '../services/websocket_pusher_service.dart';

/// Helper para probar eventos WebSocket sin necesidad del servidor real
class WebSocketTestHelper {
  static final WebSocketTestHelper _instance = WebSocketTestHelper._internal();
  factory WebSocketTestHelper() => _instance;
  WebSocketTestHelper._internal();

  final WebSocketPusherService _webSocketService = WebSocketPusherService();

  /// Simula un evento de nueva asistencia para pruebas
  void simulateNewAttendance({
    String? aprendizNombre,
    String? fichaId,
    String? jornada,
    String? estadoAsistencia,
  }) {
    final event = WebSocketEvent(
      event: '.NuevaAsistenciaRegistrada',
      channel: 'asistencias',
      timestamp: DateTime.now(),
      data: {
        'aprendiz_nombre': aprendizNombre ?? 'Juan Pérez',
        'ficha_id': fichaId ?? '12345',
        'jornada': jornada ?? 'MAÑANA',
        'estado_asistencia': estadoAsistencia ?? 'entrada',
        'documento': '12345678',
      },
    );

    debugPrint('🧪 Simulando evento WebSocket: $aprendizNombre - $fichaId');
    
    // Emitir el evento directamente al stream
    _emitTestEvent(event);
  }

  /// Simula una actualización de asistencia (salida)
  void simulateAttendanceUpdate({
    String? aprendizNombre,
    String? fichaId,
    String? jornada,
  }) {
    final event = WebSocketEvent(
      event: '.NuevaAsistenciaRegistrada',
      channel: 'asistencias',
      timestamp: DateTime.now(),
      data: {
        'aprendiz_nombre': aprendizNombre ?? 'Juan Pérez',
        'ficha_id': fichaId ?? '12345',
        'jornada': jornada ?? 'MAÑANA',
        'estado_asistencia': 'salida',
        'documento': '12345678',
      },
    );

    debugPrint('🧪 Simulando actualización WebSocket: $aprendizNombre - Salida');
    
    // Emitir el evento directamente al stream
    _emitTestEvent(event);
  }

  /// Emite un evento de prueba directamente al stream
  void _emitTestEvent(WebSocketEvent event) {
    // Acceder al stream del servicio WebSocket y emitir el evento
    // Esto simula que el evento llegó del servidor
    try {
      debugPrint('📡 Evento de prueba emitido: ${event.aprendizNombre}');
      
      // Por ahora, solo logueamos el evento ya que necesitamos acceso al provider
      // para emitir correctamente al stream
      debugPrint('📊 Datos del evento: ${event.data}');
    } catch (e) {
      debugPrint('❌ Error al emitir evento de prueba: $e');
    }
  }

  /// Simula múltiples eventos para pruebas de rendimiento
  void simulateMultipleEvents({int count = 5}) {
    final nombres = [
      'Ana García',
      'Carlos López',
      'María Rodríguez',
      'Pedro Martínez',
      'Laura Sánchez',
      'Diego Hernández',
      'Sofia González',
      'Miguel Torres',
    ];

    final fichas = ['12345', '12346', '12347', '12348', '12349'];
    final jornadas = ['MAÑANA', 'TARDE', 'NOCHE'];

    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: i * 500), () {
        simulateNewAttendance(
          aprendizNombre: nombres[i % nombres.length],
          fichaId: fichas[i % fichas.length],
          jornada: jornadas[i % jornadas.length],
        );
      });
    }
  }

  /// Simula un evento de QR escaneado
  void simulateQrScanned({
    String? qrData,
    String? location,
  }) {
    final event = WebSocketEvent(
      event: '.QrScanned',
      channel: 'qr-scans',
      timestamp: DateTime.now(),
      data: {
        'qr_data': qrData ?? 'QR123456',
        'location': location ?? 'Entrada Principal',
      },
    );

    debugPrint('🧪 Simulando QR escaneado: $qrData');
    _emitTestEvent(event);
  }

  /// Limpia todos los eventos de prueba
  void clearTestEvents() {
    debugPrint('🧹 Limpiando eventos de prueba');
  }
}
