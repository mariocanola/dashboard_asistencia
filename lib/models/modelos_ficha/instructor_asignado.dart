import 'instructor.dart';

/// Modelo de instructor asignado.
class InstructorAsignado {
  final int id;
  final String fechaInicio;
  final String fechaFin;
  final int totalHoras;
  final Instructor instructor;

  const InstructorAsignado({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.totalHoras,
    required this.instructor,
  });

  factory InstructorAsignado.fromJson(Map<String, dynamic> json) => InstructorAsignado(
        id: json['id'],
        fechaInicio: json['fecha_inicio'],
        fechaFin: json['fecha_fin'],
        totalHoras: json['total_horas'],
        instructor: Instructor.fromJson(json['instructor']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
        'total_horas': totalHoras,
        'instructor': instructor.toJson(),
      };
}