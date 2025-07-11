/// Modelo de modalidad de formación.
class ModalidadFormacion {
  final int id;
  final String nombre;

  const ModalidadFormacion({
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