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

  // Obtener las estadísticas de asistencia
  Future<Map<String, EstadisticasJornada>> getEstadisticas() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl${ApiConstants.estadisticas}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, EstadisticasJornada> estadisticas = {};
        
        for (var entry in data.entries) {
          estadisticas[entry.key] = EstadisticasJornada.fromJson(entry.value);
        }
        
        return estadisticas;
      } else {
        throw Exception('Error al cargar las estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener las asistencias por jornada
  Future<List<Asistencia>> getAsistenciasPorJornada(int jornadaId) async {
    try {
      final url = '$baseUrl${ApiConstants.fichas}/jornada/$jornadaId';
      print('Llamando a: $url');
      final response = await httpClient.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          print('Datos recibidos de la API: $data');
        } else {
          print('No llegaron datos de la API');
        }
        return data.map((item) => Asistencia.fromJson(item)).toList();
      } else {
        print('Error al cargar las fichas: ${response.statusCode}');
        throw Exception('Error al cargar las asistencias: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener las fichas de caracterización
  Future<List<FichaModel>> getFichas() async {
    try {
      final url = '$baseUrl${ApiConstants.fichas}/all';
      print('Llamando a: $url');
      final response = await httpClient.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final respuesta = RespuestaGeneral.fromJson(data);
        print('Fichas recibidas: ${respuesta.data.length}');
        return respuesta.data;
      } else {
        print('Error al cargar las fichas: ${response.statusCode}');
        throw Exception('Error al cargar las fichas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener la cantidad de aprendices por ficha
  Future<int> getCantidadAprendicesPorFicha(int fichaId) async {
    try {
      final url = '$baseUrl/fichas-caracterizacion/aprendices/$fichaId';
      print('Llamando a: $url');
      final response = await httpClient.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final cantidad = data['cantidad_aprendices'] ?? 0;
        print('Cantidad aprendices ficha $fichaId: $cantidad');
        return cantidad;
      } else {
        print('Error al cargar cantidad de aprendices: ${response.statusCode}');
        throw Exception('Error al cargar cantidad de aprendices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Cerrar la conexión
  void dispose() {
    httpClient.close();
  }
}