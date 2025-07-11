class ApiConstants {
  /// URL base de la API
  static const String baseUrl = 'http://10.7.49.240:8000/api';

  /// Endpoints
  static const String asistencias = '/asistencias';
  static const String estadisticas = '/estadisticas';
  static const String actualizaciones = '/actualizaciones';
  static const String fichas = '/fichas-caracterizacion';

  /// Tiempo de actualización en segundos
  static const int refreshTime = 300;
}

class JornadaConstants {
  static const String manana = 'MAÑANA';
  static const String tarde = 'TARDE';
  static const String noche = 'NOCHE';

  /// Lista de todas las jornadas
  static List<String> get todas => [manana, tarde, noche];

  /// Horarios de las jornadas
  static final Map<String, Map<String, String>> _horarios = {
    manana: {'inicio': '06:30', 'fin': '13:00'},
    tarde: {'inicio': '13:00', 'fin': '18:00'},
    noche: {'inicio': '18:00', 'fin': '23:00'},
  };

  /// Obtiene el horario de una jornada
  static Map<String, String>? getHorario(String jornada) => _horarios[jornada];

  /// Retorna 1 para Mañana, 2 para Tarde, 3 para Noche, 0 si está fuera de jornada
  static int getJornadaActual() {
    final now = DateTime.now();
    final horaActual = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    for (var i = 0; i < todas.length; i++) {
      final jornada = todas[i];
      final horario = getHorario(jornada)!;
      if (horaActual.compareTo(horario['inicio']!) >= 0 &&
          horaActual.compareTo(horario['fin']!) < 0) {
        return i + 1;
      }
    }
    return 0;
  }

  /// Convierte el número de jornada (1, 2, 3) a su string correspondiente
  static String getJornadaString(int jornada) {
    if (jornada >= 1 && jornada <= todas.length) {
      return todas[jornada - 1];
    }
    return '';
  }
}

class AppThemes {
  /// Colores principales
  static const int primaryColor = 0xFF0066B2;
  static const int secondaryColor = 0xFFF3A600;
  static const int backgroundColor = 0xFFF5F5F5;
  static const int textColor = 0xFF333333;
  static const int successColor = 0xFF4CAF50;
  static const int warningColor = 0xFFFFC107;
  static const int errorColor = 0xFFF44336;

  /// Tamaños de fuente
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 18.0;
  static const double fontSizeLarge = 24.0;
  static const double fontSizeXLarge = 32.0;
  static const double fontSizeXXLarge = 48.0;
}
