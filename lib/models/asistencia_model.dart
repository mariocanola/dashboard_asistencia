class Asistencia {
  final String id;
  final String ficha;
  final String programa;
  final String jornada;
  final int aprendicesEsperados;
  final int aprendicesPresentes;
  final DateTime fechaActualizacion;

  Asistencia({
    required this.id,
    required this.ficha,
    required this.programa,
    required this.jornada,
    required this.aprendicesEsperados,
    required this.aprendicesPresentes,
    required this.fechaActualizacion,
  });

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      id: json['id'] ?? '',
      ficha: json['ficha'] ?? '',
      programa: json['programa'] ?? '',
      jornada: json['jornada'] ?? '',
      aprendicesEsperados: json['aprendices_esperados'] ?? 0,
      aprendicesPresentes: json['aprendices_presentes'] ?? 0,
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ficha': ficha,
      'programa': programa,
      'jornada': jornada,
      'aprendices_esperados': aprendicesEsperados,
      'aprendices_presentes': aprendicesPresentes,
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  // Método para calcular el porcentaje de asistencia
  double get porcentajeAsistencia {
    if (aprendicesEsperados == 0) return 0.0;
    return (aprendicesPresentes / aprendicesEsperados) * 100;
  }

  // Método para obtener la cantidad de aprendices faltantes
  int get aprendicesFaltantes {
    return aprendicesEsperados - aprendicesPresentes;
  }
}
