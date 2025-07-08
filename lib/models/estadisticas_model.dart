class EstadisticasJornada {
  final String jornada;
  final int totalAprendices;
  final int totalPresentes;
  final List<EstadisticasPrograma> programas;

  EstadisticasJornada({
    required this.jornada,
    required this.totalAprendices,
    required this.totalPresentes,
    required this.programas,
  });

  factory EstadisticasJornada.fromJson(Map<String, dynamic> json) {
    return EstadisticasJornada(
      jornada: json['jornada'] ?? '',
      totalAprendices: json['total_aprendices'] ?? 0,
      totalPresentes: json['total_presentes'] ?? 0,
      programas: (json['programas'] as List<dynamic>?)
              ?.map((e) => EstadisticasPrograma.fromJson(e))
              .toList() ??
          [],
    );
  }

  // Método para calcular el porcentaje de asistencia general
  double get porcentajeAsistencia {
    if (totalAprendices == 0) return 0.0;
    return (totalPresentes / totalAprendices) * 100;
  }
}

class EstadisticasPrograma {
  final String nombre;
  final int aprendicesEsperados;
  final int aprendicesPresentes;
  final List<String> fichas;

  EstadisticasPrograma({
    required this.nombre,
    required this.aprendicesEsperados,
    required this.aprendicesPresentes,
    required this.fichas,
  });

  factory EstadisticasPrograma.fromJson(Map<String, dynamic> json) {
    return EstadisticasPrograma(
      nombre: json['nombre'] ?? '',
      aprendicesEsperados: json['aprendices_esperados'] ?? 0,
      aprendicesPresentes: json['aprendices_presentes'] ?? 0,
      fichas: List<String>.from(json['fichas'] ?? []),
    );
  }

  // Método para calcular el porcentaje de asistencia por programa
  double get porcentajeAsistencia {
    if (aprendicesEsperados == 0) return 0.0;
    return (aprendicesPresentes / aprendicesEsperados) * 100;
  }

  // Método para obtener la cantidad de aprendices faltantes
  int get aprendicesFaltantes {
    return aprendicesEsperados - aprendicesPresentes;
  }
}
