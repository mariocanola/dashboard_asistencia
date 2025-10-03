import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/asistencia_detalle_model.dart';
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

  /// Obtiene las asistencias por jornada desde el nuevo endpoint
  /// Endpoint: GET /api/asistencia/jornada?fecha=Y-m-d
  /// Si no se especifica jornada_id, trae todas las jornadas
  /// Si no se especifica fecha, usa la fecha actual
  Future<AsistenciaJornadaResponse> getAsistenciasPorJornada({
    int? jornadaId,
    DateTime? fecha,
  }) async {
    // Usar fecha actual si no se especifica
    final fechaStr = fecha != null
        ? DateFormat('yyyy-MM-dd').format(fecha)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    String endpoint = ApiConstants.asistenciaJornada;
    final params = <String>[];

    // Solo agregar jornada_id si se especifica (para filtrar por jornada específica)
    // Si no se envía, el backend devuelve todas las jornadas
    if (jornadaId != null && jornadaId > 0) {
      params.add('jornada_id=$jornadaId');
    }

    // Siempre agregar la fecha
    params.add('fecha=$fechaStr');

    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }

    try {
      debugPrint('🔍 Consultando asistencias: $endpoint');
      final response = await _get(endpoint);
      final Map<String, dynamic> data = _decodeResponse(response);

      debugPrint('✅ Asistencias obtenidas: ${data['total_asistencias'] ?? 0}');
      debugPrint('📊 Total asistencias en lista: ${(data['asistencias'] as List?)?.length ?? 0}');
      debugPrint('📊 Jornadas encontradas: ${(data['por_jornada'] as Map?)?.keys.toList() ?? []}');
      
      // Debug detallado del JSON recibido
      debugPrint('🔍 JSON completo recibido: ${jsonEncode(data)}');

      return AsistenciaJornadaResponse.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error al obtener asistencias por jornada: $e');
      rethrow;
    }
  }

  /// Obtiene las estadísticas de asistencia calculadas desde las asistencias
  Future<Map<String, EstadisticasJornada>> getEstadisticas() async {
    try {
      // Obtener asistencias del día actual
      final response = await getAsistenciasPorJornada();

      // Calcular estadísticas por jornada
      final Map<String, EstadisticasJornada> estadisticas = {};

      response.porJornada.forEach((jornada, asistencias) {
        // Contar presentes (asistencias con entrada)
        final presentes = asistencias.length;

        // Obtener el total real de aprendices de la jornada
        // Esto debería venir del endpoint de jornada que devuelve el total de aprendices
        final totalAprendices = _getTotalAprendicesJornada(jornada, asistencias);

        estadisticas[jornada] = EstadisticasJornada(
          jornada: jornada,
          totalAprendices: totalAprendices, // Total real de aprendices de la jornada
          totalPresentes: presentes,
          programas: [], // Agrupar por programas si es necesario
        );
      });

      return estadisticas;
    } catch (e) {
      debugPrint('❌ Error al obtener estadísticas: $e');
      return {};
    }
  }

  /// Obtiene el total real de aprendices de una jornada
  /// Por ahora usa un valor fijo basado en la jornada, pero esto debería venir del backend
  int _getTotalAprendicesJornada(String jornada, List<AsistenciaDetalle> asistencias) {
    // TODO: Esto debería venir del endpoint de jornada que devuelve el total de aprendices
    // Por ahora, para la jornada MAÑANA usamos 28 como valor conocido
    // En el futuro, esto debería ser una llamada al backend
    
    switch (jornada.toUpperCase()) {
      case 'MAÑANA':
        return 28; // Valor real de aprendices en la jornada MAÑANA
      case 'TARDE':
        return 25; // Valor estimado para TARDE
      case 'NOCHE':
        return 20; // Valor estimado para NOCHE
      default:
        // Fallback: usar el número de asistencias si no se conoce el total
        return asistencias.length;
    }
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
          .timeout(const Duration(seconds: 10)); // Timeout más razonable para el servidor
      _checkStatusCode(response);
      return response;
    } on TimeoutException {
      throw Exception('Timeout: La petición tardó demasiado (10s)');
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
      String errorMessage = 'Error en la petición: ${response.statusCode}';

      // Mensajes específicos para códigos comunes
      switch (response.statusCode) {
        case 500:
          errorMessage =
              'Error del servidor (500): El backend Laravel tiene un problema interno';
          break;
        case 404:
          errorMessage =
              'Endpoint no encontrado (404): Verifica que la ruta exista en Laravel';
          break;
        case 403:
          errorMessage =
              'Acceso denegado (403): Problema de permisos en Laravel';
          break;
        case 401:
          errorMessage = 'No autorizado (401): Problema de autenticación';
          break;
      }

      debugPrint('❌ API Error: $errorMessage');
      debugPrint('📄 Response body: ${response.body}');
      throw Exception(errorMessage);
    }
  }

  /// Construye los headers para las peticiones
  Map<String, String> _headers() => {'Content-Type': 'application/json'};
}
