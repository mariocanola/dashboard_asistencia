/// Modelo de sede.
class Sede {
  final int id;
  final String sede;
  final String direccion;

  const Sede({
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
