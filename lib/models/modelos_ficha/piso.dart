import 'bloque.dart';

/// Modelo de piso.
class Piso {
  final int id;
  final String piso;
  final Bloque bloque;

  const Piso({
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