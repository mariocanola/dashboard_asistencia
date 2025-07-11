/// Modelo que representa la asistencia de una ficha en un programa.
class Asistencia {
  final String id;
  final String ficha;
  final String programa;
  final String jornada;
  final int aprendicesEsperados;
  final int aprendicesPresentes;
  final DateTime fechaActualizacion;

  const Asistencia({
    required this.id,
    required this.ficha,
    required this.programa,
    required this.jornada,
    required this.aprendicesEsperados,
    required this.aprendicesPresentes,
    required this.fechaActualizacion,
  });

  /// Crea una instancia de [Asistencia] a partir de un mapa JSON.
  factory Asistencia.fromJson(Map<String, dynamic> json) => Asistencia(
        id: json['id'] ?? '',
        ficha: json['ficha'] ?? '',
        programa: json['programa'] ?? '',
        jornada: json['jornada'] ?? '',
        aprendicesEsperados: json['aprendices_esperados'] ?? 0,
        aprendicesPresentes: json['aprendices_presentes'] ?? 0,
        fechaActualizacion: DateTime.tryParse(json['fecha_actualizacion'] ?? '') ?? DateTime.now(),
      );

  /// Convierte la instancia en un mapa JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'ficha': ficha,
        'programa': programa,
        'jornada': jornada,
        'aprendices_esperados': aprendicesEsperados,
        'aprendices_presentes': aprendicesPresentes,
        'fecha_actualizacion': fechaActualizacion.toIso8601String(),
      };

  /// Porcentaje de asistencia de los aprendices.
  double get porcentajeAsistencia =>
      aprendicesEsperados == 0 ? 0.0 : (aprendicesPresentes / aprendicesEsperados) * 100;

  /// Cantidad de aprendices que faltaron.
  int get aprendicesFaltantes => aprendicesEsperados - aprendicesPresentes;
}