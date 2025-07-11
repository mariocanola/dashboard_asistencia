/// Modelo de jornada de formación.
class JornadaFormacion {
  final int id;
  final String jornada;

  const JornadaFormacion({
    required this.id,
    required this.jornada,
  });

  factory JornadaFormacion.fromJson(Map<String, dynamic> json) => JornadaFormacion(
        id: json['id'],
        jornada: json['jornada'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'jornada': jornada,
      };
}