class ProgramaFormacion {
  final int id;
  final String nombre;
  final int codigo;
  final String nivelFormacion;

  const ProgramaFormacion({
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