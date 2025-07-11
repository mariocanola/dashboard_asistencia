import 'persona.dart';


/// Modelo de instructor principal.
class InstructorPrincipal {
  final int id;
  final Persona persona;

  const InstructorPrincipal({
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