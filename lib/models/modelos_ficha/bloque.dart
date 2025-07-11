/// Modelo de bloque.
class Bloque {
  final int id;
  final String nombre;

  const Bloque({
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