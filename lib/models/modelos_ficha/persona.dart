/// Modelo de persona.
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

  const Persona({
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