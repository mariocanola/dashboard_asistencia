import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/asistencia_model.dart';
import '../models/estadisticas_model.dart';
import '../utils/constants.dart';
import '../models/respuesta_general.dart';
import '../models/ficha_model.dart';

class ApiService {
  final String baseUrl;
  final http.Client httpClient;

  ApiService({http.Client? httpClient, String? baseUrl})
      : httpClient = httpClient ?? http.Client(),
        baseUrl = baseUrl ?? ApiConstants.baseUrl;

  /// Obtiene las estadísticas de asistencia
  Future<Map<String, EstadisticasJornada>> getEstadisticas() async {
    // Retornar estadísticas vacías hasta que haya datos reales de asistencia
    return {};
  }

  /// Obtiene las asistencias por jornada
  Future<List<Asistencia>> getAsistenciasPorJornada(int jornadaId) async {
    // Retornar lista vacía hasta que haya datos reales de asistencia
    return [];
  }

  /// Obtiene las fichas de caracterización
  Future<List<FichaModel>> getFichas() async {
    final response = await _get('${ApiConstants.fichas}/all');
    final Map<String, dynamic> data = _decodeResponse(response);
    final respuesta = RespuestaGeneral.fromJson(data);
    return respuesta.data;
  }

  /// Obtiene la cantidad de aprendices por ficha
  Future<int> getCantidadAprendicesPorFicha(int fichaId) async {
    final response = await _get('${ApiConstants.aprendicesPorFicha}/$fichaId');
    final Map<String, dynamic> data = _decodeResponse(response);
    return data['cantidad_aprendices'] ?? 0;
  }

  /// Cierra la conexión HTTP
  void dispose() {
    httpClient.close();
  }

  // --- Métodos privados auxiliares ---

  /// Realiza una petición GET a la API
  Future<http.Response> _get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await httpClient
          .get(url, headers: _headers())
          .timeout(const Duration(seconds: 15)); // Reducido de 30 a 15 segundos
      _checkStatusCode(response);
      return response;
    } on TimeoutException {
      throw Exception('Timeout: La petición tardó demasiado (15s)');
    } on http.ClientException {
      throw Exception('Error de conexión: No se pudo conectar al servidor');
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Decodifica la respuesta HTTP
  dynamic _decodeResponse(http.Response response) {
    try {
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error al decodificar la respuesta: $e');
    }
  }

  /// Verifica el código de estado de la respuesta
  void _checkStatusCode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error en la petición: ${response.statusCode}');
    }
  }

  /// Construye los headers para las peticiones
  Map<String, String> _headers() => {'Content-Type': 'application/json'};
}
