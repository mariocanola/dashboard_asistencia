import 'dia.dart';

/// Modelo de día de formación.
class DiaFormacion {
  final int id;
  final String horaInicio;
  final String horaFin;
  final Dia dia;

  const DiaFormacion({
    required this.id,
    required this.horaInicio,
    required this.horaFin,
    required this.dia,
  });

  factory DiaFormacion.fromJson(Map<String, dynamic> json) => DiaFormacion(
        id: json['id'],
        horaInicio: json['hora_inicio'],
        horaFin: json['hora_fin'],
        dia: Dia.fromJson(json['dia']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        'dia': dia.toJson(),
      };
}