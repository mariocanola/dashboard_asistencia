class RespuestaGeneral {
  final bool success;
  final String message;
  final List<FichaModel> data;
  final int total;

  RespuestaGeneral({
    required this.success,
    required this.message,
    required this.data,
    required this.total,
  });

  factory RespuestaGeneral.fromJson(Map<String, dynamic> json) => RespuestaGeneral(
        success: json['success'],
        message: json['message'],
        data: (json['data'] as List).map((e) => FichaModel.fromJson(e)).toList(),
        total: json['total'],
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
        'total': total,
      };
}

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

  FichaModel({
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

class ProgramaFormacion {
  final int id;
  final String nombre;
  final int codigo;
  final String nivelFormacion;

  ProgramaFormacion({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.nivelFormacion,
  });

  factory ProgramaFormacion.fromJson(Map<String, dynamic> json) => ProgramaFormacion(
        id: json['id'],
        nombre: json['nombre'],
        codigo: json['codigo'],
        nivelFormacion: json['nivel_formacion'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'codigo': codigo,
        'nivel_formacion': nivelFormacion,
      };
}

class InstructorPrincipal {
  final int id;
  final Persona persona;

  InstructorPrincipal({
    required this.id,
    required this.persona,
  });

  factory InstructorPrincipal.fromJson(Map<String, dynamic> json) => InstructorPrincipal(
        id: json['id'],
        persona: Persona.fromJson(json['persona']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'persona': persona.toJson(),
      };
}

class Persona {
  final int id;
  final String primerNombre;
  final String segundoNombre;
  final String primerApellido;
  final String segundoApellido;
  final int tipoDocumento;
  final String numeroDocumento;
  final String email;
  final String telefono;

  Persona({
    required this.id,
    required this.primerNombre,
    required this.segundoNombre,
    required this.primerApellido,
    required this.segundoApellido,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.email,
    required this.telefono,
  });

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        id: json['id'],
        primerNombre: json['primer_nombre'],
        segundoNombre: json['segundo_nombre'],
        primerApellido: json['primer_apellido'],
        segundoApellido: json['segundo_apellido'],
        tipoDocumento: json['tipo_documento'],
        numeroDocumento: json['numero_documento'],
        email: json['email'],
        telefono: json['telefono'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'primer_nombre': primerNombre,
        'segundo_nombre': segundoNombre,
        'primer_apellido': primerApellido,
        'segundo_apellido': segundoApellido,
        'tipo_documento': tipoDocumento,
        'numero_documento': numeroDocumento,
        'email': email,
        'telefono': telefono,
      };
}

class JornadaFormacion {
  final int id;
  final String jornada;

  JornadaFormacion({
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

class Ambiente {
  final int id;
  final String nombre;
  final Piso piso;

  Ambiente({
    required this.id,
    required this.nombre,
    required this.piso,
  });

  factory Ambiente.fromJson(Map<String, dynamic> json) => Ambiente(
        id: json['id'],
        nombre: json['nombre'],
        piso: Piso.fromJson(json['piso']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'piso': piso.toJson(),
      };
}

class Piso {
  final int id;
  final String piso;
  final Bloque bloque;

  Piso({
    required this.id,
    required this.piso,
    required this.bloque,
  });

  factory Piso.fromJson(Map<String, dynamic> json) => Piso(
        id: json['id'],
        piso: json['piso'],
        bloque: Bloque.fromJson(json['bloque']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'piso': piso,
        'bloque': bloque.toJson(),
      };
}

class Bloque {
  final int id;
  final String nombre;

  Bloque({
    required this.id,
    required this.nombre,
  });

  factory Bloque.fromJson(Map<String, dynamic> json) => Bloque(
        id: json['id'],
        nombre: json['nombre'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
      };
}

class ModalidadFormacion {
  final int id;
  final String nombre;

  ModalidadFormacion({
    required this.id,
    required this.nombre,
  });

  factory ModalidadFormacion.fromJson(Map<String, dynamic> json) => ModalidadFormacion(
        id: json['id'],
        nombre: json['nombre'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
      };
}

class Sede {
  final int id;
  final String sede;
  final String direccion;

  Sede({
    required this.id,
    required this.sede,
    required this.direccion,
  });

  factory Sede.fromJson(Map<String, dynamic> json) => Sede(
        id: json['id'],
        sede: json['sede'],
        direccion: json['direccion'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sede': sede,
        'direccion': direccion,
      };
}

class DiaFormacion {
  final int id;
  final String horaInicio;
  final String horaFin;
  final Dia dia;

  DiaFormacion({
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

class Dia {
  final int id;
  final String nombre;

  Dia({
    required this.id,
    required this.nombre,
  });

  factory Dia.fromJson(Map<String, dynamic> json) => Dia(
        id: json['id'],
        nombre: json['nombre'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
      };
}

class InstructorAsignado {
  final int id;
  final String fechaInicio;
  final String fechaFin;
  final int totalHoras;
  final Instructor instructor;

  InstructorAsignado({
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

class Instructor {
  final int id;
  final Persona persona;

  Instructor({
    required this.id,
    required this.persona,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) => Instructor(
        id: json['id'],
        persona: Persona.fromJson(json['persona']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'persona': persona.toJson(),
      };
} 