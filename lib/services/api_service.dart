import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/asistencia_model.dart';
import '../models/estadisticas_model.dart';
import '../utils/constants.dart';

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

  // Obtener las asistencias en tiempo real
  Stream<List<Asistencia>> getAsistenciasEnTiempoReal() {
    final channel = WebSocketChannel.connect(
      Uri.parse('wss://tu-api-sena.com/ws/asistencias'),
    );

    return channel.stream.map((data) {
      try {
        final List<dynamic> jsonData = json.decode(data);
        return jsonData.map((item) => Asistencia.fromJson(item)).toList();
      } catch (e) {
        print('Error al procesar datos del WebSocket: $e');
        return <Asistencia>[];
      }
    });
  }

  // Obtener las asistencias por jornada
  Future<List<Asistencia>> getAsistenciasPorJornada(String jornada) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl${ApiConstants.asistencias}?jornada=$jornada'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Asistencia.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar las asistencias: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Cerrar la conexión
  void dispose() {
    httpClient.close();
  }
}

// --- MOCK API SERVICE PARA DATOS DE PRUEBA ---
class MockApiService extends ApiService {
  MockApiService() : super(baseUrl: 'mock');

  @override
  Future<Map<String, EstadisticasJornada>> getEstadisticas() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'Mañana': EstadisticasJornada(
        jornada: 'Mañana',
        totalAprendices: 30,
        totalPresentes: 25,
        programas: [
          EstadisticasPrograma(
            nombre: 'ADSO',
            aprendicesEsperados: 15,
            aprendicesPresentes: 13,
            fichas: ['123456', '654321'],
          ),
          EstadisticasPrograma(
            nombre: 'Contabilidad',
            aprendicesEsperados: 15,
            aprendicesPresentes: 12,
            fichas: ['789012', '210987'],
          ),
        ],
      ),
      'Tarde': EstadisticasJornada(
        jornada: 'Tarde',
        totalAprendices: 20,
        totalPresentes: 18,
        programas: [
          EstadisticasPrograma(
            nombre: 'Sistemas',
            aprendicesEsperados: 10,
            aprendicesPresentes: 9,
            fichas: ['333444'],
          ),
          EstadisticasPrograma(
            nombre: 'Salud',
            aprendicesEsperados: 10,
            aprendicesPresentes: 9,
            fichas: ['555666'],
          ),
        ],
      ),
      'Noche': EstadisticasJornada(
        jornada: 'Noche',
        totalAprendices: 10,
        totalPresentes: 7,
        programas: [
          EstadisticasPrograma(
            nombre: 'Electricidad',
            aprendicesEsperados: 10,
            aprendicesPresentes: 7,
            fichas: ['777888'],
          ),
        ],
      ),
    };
  }

  @override
  Future<List<Asistencia>> getAsistenciasPorJornada(String jornada) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Asistencia(
        id: '1',
        ficha: '123456',
        programa: 'ADSO',
        jornada: jornada,
        aprendicesEsperados: 15,
        aprendicesPresentes: 13,
        fechaActualizacion: DateTime.now(),
      ),
      Asistencia(
        id: '2',
        ficha: '654321',
        programa: 'Contabilidad',
        jornada: jornada,
        aprendicesEsperados: 15,
        aprendicesPresentes: 12,
        fechaActualizacion: DateTime.now(),
      ),
    ];
  }

  @override
  Stream<List<Asistencia>> getAsistenciasEnTiempoReal() async* {
    yield [
      Asistencia(
        id: '1',
        ficha: '123456',
        programa: 'ADSO',
        jornada: 'Mañana',
        aprendicesEsperados: 15,
        aprendicesPresentes: 13,
        fechaActualizacion: DateTime.now(),
      ),
    ];
  }
}
