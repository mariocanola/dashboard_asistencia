import 'dart:convert';

/// Modelo para representar eventos WebSocket
class WebSocketEvent {
  /// Tipo de evento recibido
  final String event;

  /// Canal donde se recibió el evento
  final String channel;

  /// Datos del evento (payload)
  final Map<String, dynamic> data;

  /// Timestamp cuando se recibió el evento
  final DateTime timestamp;

  /// ID único del evento
  final String? eventId;

  const WebSocketEvent({
    required this.event,
    required this.channel,
    required this.data,
    required this.timestamp,
    this.eventId,
  });

  /// Factory constructor para crear un evento desde JSON
  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketEvent(
      event: json['event'] ?? '',
      channel: json['channel'] ?? '',
      data: json['data'] ?? {},
      timestamp: DateTime.now(),
      eventId: json['event_id'],
    );
  }

  /// Factory constructor para crear un evento desde string JSON
  factory WebSocketEvent.fromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return WebSocketEvent.fromJson(json);
    } catch (e) {
      throw Exception('Error al parsear evento WebSocket: $e');
    }
  }

  /// Convierte el evento a JSON
  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'channel': channel,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'event_id': eventId,
    };
  }

  /// Verifica si es un evento de nueva asistencia
  /// Nota: Laravel Reverb envía eventos con punto al inicio: .NuevaAsistenciaRegistrada
  bool get isNuevaAsistencia =>
      (event == '.NuevaAsistenciaRegistrada' ||
          event == 'NuevaAsistenciaRegistrada') &&
      channel == 'asistencias';

  /// Verifica si es un evento de QR escaneado
  bool get isQrScanned =>
      (event == '.QrScanned' || event == 'QrScanned') && channel == 'qr-scans';

  /// Obtiene el ID de la asistencia del evento (según formato del backend)
  int? get asistenciaId {
    if (isNuevaAsistencia) {
      final id = data['id'] ?? data['asistencia_id'];
      if (id != null) {
        return int.tryParse(id.toString());
      }
    }
    return null;
  }

  /// Obtiene el nombre del aprendiz del evento
  String? get aprendizNombre {
    if (isNuevaAsistencia) {
      return data['aprendiz']?.toString();
    }
    return null;
  }

  /// Obtiene el estado de la asistencia (entrada/salida)
  String? get estadoAsistencia {
    if (isNuevaAsistencia) {
      return data['estado']?.toString();
    }
    return null;
  }

  /// Obtiene el ID de la ficha del evento (si existe)
  String? get fichaId {
    if (isNuevaAsistencia || isQrScanned) {
      return data['ficha']?.toString() ?? data['ficha_id']?.toString();
    }
    return null;
  }

  /// Obtiene el ID del aprendiz del evento (si existe)
  String? get aprendizId {
    if (isNuevaAsistencia || isQrScanned) {
      return data['aprendiz_id']?.toString();
    }
    return null;
  }

  /// Obtiene la jornada del evento (si existe)
  String? get jornada {
    if (isNuevaAsistencia || isQrScanned) {
      return data['jornada']?.toString();
    }
    return null;
  }

  /// Obtiene el programa del evento (si existe)
  String? get programa {
    if (isNuevaAsistencia || isQrScanned) {
      return data['programa']?.toString();
    }
    return null;
  }

  /// Obtiene el timestamp del evento
  String? get timestampEvento {
    if (isNuevaAsistencia) {
      return data['timestamp']?.toString();
    }
    return null;
  }

  /// Obtiene el tipo de evento (para diferenciar entre tipos de asistencia)
  String? get tipo {
    if (isNuevaAsistencia) {
      return data['tipo']?.toString();
    }
    return null;
  }

  /// Verifica si el evento tiene datos válidos
  bool get hasValidData {
    if (isNuevaAsistencia) {
      return asistenciaId != null && aprendizNombre != null;
    }
    if (isQrScanned) {
      return fichaId != null && aprendizId != null;
    }
    return false;
  }

  @override
  String toString() {
    return 'WebSocketEvent(event: $event, channel: $channel, data: $data, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebSocketEvent &&
        other.event == event &&
        other.channel == channel &&
        other.timestamp == timestamp &&
        other.eventId == eventId;
  }

  @override
  int get hashCode {
    return Object.hash(event, channel, timestamp, eventId);
  }
}
