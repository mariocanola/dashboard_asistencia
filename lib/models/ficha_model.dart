import 'modelos_ficha/programa_formacion.dart';
import 'modelos_ficha/instructor_principal.dart';
import 'modelos_ficha/ambiente.dart';
import 'modelos_ficha/dias_formacion.dart';
import 'modelos_ficha/jornada_formacion.dart';
import 'modelos_ficha/modalidad_formacion.dart';
import 'modelos_ficha/sede.dart';
import 'modelos_ficha/instructor_asignado.dart';

/// Modelo de ficha.
class FichaModel {
  final int id;
  final int numeroFicha;
  final String fechaInicio;
  final String fechaFin;
  final int totalHoras;
  final int status;
  final ProgramaFormacion programaFormacion;
  final InstructorPrincipal instructorPrincipal;
  final JornadaFormacion jornadaFormacion;
  final Ambiente ambiente;
  final ModalidadFormacion modalidadFormacion;
  final Sede sede;
  final List<DiaFormacion> diasFormacion;
  final List<InstructorAsignado> instructoresAsignados;
  final String createdAt;
  final String updatedAt;

  const FichaModel({
    required this.id,
    required this.numeroFicha,
    required this.fechaInicio,
    required this.fechaFin,
    required this.totalHoras,
    required this.status,
    required this.programaFormacion,
    required this.instructorPrincipal,
    required this.jornadaFormacion,
    required this.ambiente,
    required this.modalidadFormacion,
    required this.sede,
    required this.diasFormacion,
    required this.instructoresAsignados,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FichaModel.fromJson(Map<String, dynamic> json) => FichaModel(
        id: json['id'],
        numeroFicha: json['numero_ficha'],
        fechaInicio: json['fecha_inicio'],
        fechaFin: json['fecha_fin'],
        totalHoras: json['total_horas'],
        status: json['status'],
        programaFormacion: ProgramaFormacion.fromJson(json['programa_formacion']),
        instructorPrincipal: InstructorPrincipal.fromJson(json['instructor_principal']),
        jornadaFormacion: JornadaFormacion.fromJson(json['jornada_formacion']),
        ambiente: Ambiente.fromJson(json['ambiente']),
        modalidadFormacion: ModalidadFormacion.fromJson(json['modalidad_formacion']),
        sede: Sede.fromJson(json['sede']),
        diasFormacion: (json['dias_formacion'] as List)
            .map((e) => DiaFormacion.fromJson(e))
            .toList(),
        instructoresAsignados: (json['instructores_asignados'] as List)
            .map((e) => InstructorAsignado.fromJson(e))
            .toList(),
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero_ficha': numeroFicha,
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
        'total_horas': totalHoras,
        'status': status,
        'programa_formacion': programaFormacion.toJson(),
        'instructor_principal': instructorPrincipal.toJson(),
        'jornada_formacion': jornadaFormacion.toJson(),
        'ambiente': ambiente.toJson(),
        'modalidad_formacion': modalidadFormacion.toJson(),
        'sede': sede.toJson(),
        'dias_formacion': diasFormacion.map((e) => e.toJson()).toList(),
        'instructores_asignados': instructoresAsignados.map((e) => e.toJson()).toList(),
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}