import 'piso.dart';

/// Modelo de ambiente.
class Ambiente {
  final int id;
  final String nombre;
  final Piso piso;

  const Ambiente({
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