import 'persona.dart';

/// Modelo de instructor.
class Instructor {
  final int id;
  final Persona persona;

  const Instructor({
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