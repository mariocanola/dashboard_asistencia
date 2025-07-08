class ApiConstants {
  // URL base de la API (deberás reemplazarla con la URL real)
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Endpoints
  static const String asistencias = '/asistencias';
  static const String estadisticas = '/estadisticas';
  static const String actualizaciones = '/actualizaciones';

  // Tiempo de actualización en segundos
  static const int refreshTime = 30;
}

class JornadaConstants {
  static const String manana = 'Mañana';
  static const String tarde = 'Tarde';
  static const String noche = 'Noche';
  
  static List<String> get todas => [manana, tarde, noche];
  
  // Horarios de las jornadas
  static Map<String, Map<String, String>> horarios = {
    manana: {'inicio': '06:30', 'fin': '13:00'},
    tarde: {'inicio': '13:00', 'fin': '18:00'},
    noche: {'inicio': '18:00', 'fin': '23:00'},
  };
  
  // Obtener la jornada actual basada en la hora
  static String getJornadaActual() {
    final now = DateTime.now();
    final horaActual = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    for (var entry in horarios.entries) {
      final inicio = entry.value['inicio']!;
      final fin = entry.value['fin']!;
      
      if (horaActual.compareTo(inicio) >= 0 && horaActual.compareTo(fin) < 0) {
        return entry.key;
      }
    }
    
    return ''; // Fuera del horario de las jornadas
  }
}

class AppThemes {
  // Colores principales
  static const int primaryColor = 0xFF0066B2; // Azul SENA
  static const int secondaryColor = 0xFFF3A600; // Amarillo SENA
  static const int backgroundColor = 0xFFF5F5F5;
  static const int textColor = 0xFF333333;
  static const int successColor = 0xFF4CAF50;
  static const int warningColor = 0xFFFFC107;
  static const int errorColor = 0xFFF44336;
  
  // Tamaños de fuente
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 18.0;
  static const double fontSizeLarge = 24.0;
  static const double fontSizeXLarge = 32.0;
  static const double fontSizeXXLarge = 48.0;
}
