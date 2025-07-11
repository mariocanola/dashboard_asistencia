/// Modelo que representa las estadísticas de asistencia por jornada.
class EstadisticasJornada {
  final String jornada;
  final int totalAprendices;
  final int totalPresentes;
  final List<EstadisticasPrograma> programas;

  const EstadisticasJornada({
    required this.jornada,
    required this.totalAprendices,
    required this.totalPresentes,
    required this.programas,
  });

  /// Crea una instancia de [EstadisticasJornada] a partir de un mapa JSON.
  factory EstadisticasJornada.fromJson(Map<String, dynamic> json) => EstadisticasJornada(
        jornada: json['jornada'] ?? '',
        totalAprendices: json['total_aprendices'] ?? 0,
        totalPresentes: json['total_presentes'] ?? 0,
        programas: (json['programas'] as List<dynamic>?)
                ?.map((e) => EstadisticasPrograma.fromJson(e))
                .toList() ??
            [],
      );

  /// Porcentaje de asistencia general de la jornada.
  double get porcentajeAsistencia =>
      totalAprendices == 0 ? 0.0 : (totalPresentes / totalAprendices) * 100;
}

/// Modelo que representa las estadísticas de asistencia por programa.
class EstadisticasPrograma {
  final String nombre;
  final int aprendicesEsperados;
  final int aprendicesPresentes;
  final List<String> fichas;

  const EstadisticasPrograma({
    required this.nombre,
    required this.aprendicesEsperados,
    required this.aprendicesPresentes,
    required this.fichas,
  });

  /// Crea una instancia de [EstadisticasPrograma] a partir de un mapa JSON.
  factory EstadisticasPrograma.fromJson(Map<String, dynamic> json) => EstadisticasPrograma(
        nombre: json['nombre'] ?? '',
        aprendicesEsperados: json['aprendices_esperados'] ?? 0,
        aprendicesPresentes: json['aprendices_presentes'] ?? 0,
        fichas: List<String>.from(json['fichas'] ?? []),
      );

  /// Porcentaje de asistencia del programa.
  double get porcentajeAsistencia =>
      aprendicesEsperados == 0 ? 0.0 : (aprendicesPresentes / aprendicesEsperados) * 100;

  /// Cantidad de aprendices que faltaron en el programa.
  int get aprendicesFaltantes => aprendicesEsperados - aprendicesPresentes;
}
