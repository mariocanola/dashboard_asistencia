import 'ficha_model.dart';

/// Modelo de respuesta general para fichas.
class RespuestaGeneral {
  final bool success;
  final String message;
  final List<FichaModel> data;
  final int total;

  const RespuestaGeneral({
    required this.success,
    required this.message,
    required this.data,
    required this.total,
  });

  factory RespuestaGeneral.fromJson(Map<String, dynamic> json) => RespuestaGeneral(
        success: json['success'],
        message: json['message'],
        data: (json['data'] as List).map((e) => FichaModel.fromJson(e)).toList(),
        total: json['total'],
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
        'total': total,
      };
}