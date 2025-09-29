/// Modelo que representa una asistencia individual según la respuesta del backend
/// Endpoint: GET /api/asistencia/jornada
class AsistenciaDetalle {
  final int id;
  final String aprendiz;
  final String numeroDocumento;
  final String horaIngreso;
  final String? horaSalida;
  final String ficha; // Se convierte a String para manejar cualquier formato
  final String jornada;
  final int jornadaId;
  final String fecha;
  final String estado; // Estados: "en_curso", "completa", "pendiente"

  const AsistenciaDetalle({
    required this.id,
    required this.aprendiz,
    required this.numeroDocumento,
    required this.horaIngreso,
    this.horaSalida,
    required this.ficha,
    required this.jornada,
    required this.jornadaId,
    required this.fecha,
    required this.estado,
  });

  /// Crea una instancia desde JSON según formato del backend
  factory AsistenciaDetalle.fromJson(Map<String, dynamic> json) {
    return AsistenciaDetalle(
      id: json['id'] ?? 0,
      aprendiz: json['aprendiz'] ?? '',
      numeroDocumento: json['numero_documento'] ?? '',
      horaIngreso: json['hora_ingreso'] ?? '',
      horaSalida: json['hora_salida'],
      ficha: json['ficha']?.toString() ??
          '', // Convertir a String (puede venir como int o String)
      jornada: json['jornada'] ?? '',
      jornadaId: json['jornada_id'] ?? 0,
      fecha: json['fecha'] ?? '',
      estado: json['estado'] ?? '',
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aprendiz': aprendiz,
      'numero_documento': numeroDocumento,
      'hora_ingreso': horaIngreso,
      'hora_salida': horaSalida,
      'ficha': ficha,
      'jornada': jornada,
      'jornada_id': jornadaId,
      'fecha': fecha,
      'estado': estado,
    };
  }

  /// Verifica si la asistencia está completa (tiene entrada y salida)
  bool get isCompleta =>
      estado == 'completa' || (horaSalida != null && horaSalida!.isNotEmpty);

  /// Verifica si la asistencia está en curso (solo tiene entrada)
  bool get isEnCurso =>
      estado == 'en_curso' ||
      estado == 'pendiente' ||
      (horaSalida == null || horaSalida!.isEmpty);

  /// Verifica si la asistencia está pendiente (solo tiene entrada) - alias
  bool get isPendiente => isEnCurso;

  @override
  String toString() {
    return 'AsistenciaDetalle(id: $id, aprendiz: $aprendiz, ficha: $ficha, estado: $estado)';
  }
}

/// Modelo para la respuesta completa del endpoint /asistencia/jornada
class AsistenciaJornadaResponse {
  final String status;
  final String fecha;
  final int totalAsistencias;
  final List<AsistenciaDetalle> asistencias;
  final Map<String, List<AsistenciaDetalle>> porJornada;

  const AsistenciaJornadaResponse({
    required this.status,
    required this.fecha,
    required this.totalAsistencias,
    required this.asistencias,
    required this.porJornada,
  });

  /// Crea una instancia desde JSON
  factory AsistenciaJornadaResponse.fromJson(Map<String, dynamic> json) {
    final List<AsistenciaDetalle> asistenciasList = [];
    if (json['asistencias'] != null) {
      for (var item in json['asistencias']) {
        asistenciasList.add(AsistenciaDetalle.fromJson(item));
      }
    }

    final Map<String, List<AsistenciaDetalle>> porJornadaMap = {};
    if (json['por_jornada'] != null) {
      final Map<String, dynamic> porJornadaData = json['por_jornada'];
      porJornadaData.forEach((key, value) {
        final List<AsistenciaDetalle> jornadaList = [];
        if (value is List) {
          for (var item in value) {
            jornadaList.add(AsistenciaDetalle.fromJson(item));
          }
        }
        porJornadaMap[key] = jornadaList;
      });
    }

    return AsistenciaJornadaResponse(
      status: json['status'] ?? 'success',
      fecha: json['fecha'] ?? '',
      totalAsistencias: json['total_asistencias'] ?? 0,
      asistencias: asistenciasList,
      porJornada: porJornadaMap,
    );
  }

  /// Obtiene las asistencias de una jornada específica
  List<AsistenciaDetalle> getAsistenciasJornada(String jornada) {
    return porJornada[jornada] ?? [];
  }

  @override
  String toString() {
    return 'AsistenciaJornadaResponse(fecha: $fecha, total: $totalAsistencias, jornadas: ${porJornada.keys.toList()})';
  }
}
