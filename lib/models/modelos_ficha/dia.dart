/// Modelo de día.
class Dia {
  final int id;
  final String nombre;

  const Dia({
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