import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Servicio de prueba para verificar el endpoint de asistencias
class TestEndpointService {
  static const String baseUrl = 'http://10.7.55.172:8000/api';
  
  /// Prueba el endpoint de asistencias directamente
  static Future<void> testAsistenciasEndpoint() async {
    try {
      final fecha = DateTime.now();
      final fechaStr = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      
      final url = Uri.parse('$baseUrl/asistencia/jornada?fecha=$fechaStr');
      
      debugPrint('🧪 Probando endpoint directamente: $url');
      
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      debugPrint('🧪 Status Code: ${response.statusCode}');
      debugPrint('🧪 Headers: ${response.headers}');
      debugPrint('🧪 Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('🧪 JSON parseado: $data');
        
        if (data is Map<String, dynamic>) {
          debugPrint('🧪 Total asistencias: ${data['total_asistencias']}');
          debugPrint('🧪 Asistencias en lista: ${(data['asistencias'] as List?)?.length}');
          debugPrint('🧪 Por jornada: ${data['por_jornada']}');
        }
      } else {
        debugPrint('🧪 Error en respuesta: ${response.statusCode}');
      }
      
    } catch (e) {
      debugPrint('🧪 Error en prueba: $e');
    }
  }
  
  /// Prueba el endpoint sin parámetros de fecha
  static Future<void> testAsistenciasSinFecha() async {
    try {
      final url = Uri.parse('$baseUrl/asistencia/jornada');
      
      debugPrint('🧪 Probando endpoint sin fecha: $url');
      
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      debugPrint('🧪 Status Code: ${response.statusCode}');
      debugPrint('🧪 Body: ${response.body}');
      
    } catch (e) {
      debugPrint('🧪 Error en prueba sin fecha: $e');
    }
  }
}
