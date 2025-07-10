class ApiConstants {
  // URL base de la API (deberás reemplazarla con la URL real)
  static const String baseUrl = 'http://192.168.100.79:8000/api';
  
  // Endpoints
  static const String asistencias = '/asistencias';
  static const String estadisticas = '/estadisticas';
  static const String actualizaciones = '/actualizaciones';
  static const String fichas = '/fichas-caracterizacion/all'; // Ajusta esta ruta si es diferente en tu backend

  // Tiempo de actualización en segundos
  static const int refreshTime = 300;
}

class JornadaConstants {
  static const String manana = 'MAÑANA';
  static const String tarde = 'TARDE';
  static const String noche = 'NOCHE';
  
  static List<String> get todas => [manana, tarde, noche];
  
  // Horarios de las jornadas
  static Map<String, Map<String, String>> horarios = {
    manana: {'inicio': '06:30', 'fin': '13:00'},
    tarde: {'inicio': '13:00', 'fin': '18:00'},
    noche: {'inicio': '18:00', 'fin': '23:00'},
  };
  
  // Retorna 1 para Mañana, 2 para Tarde, 3 para Noche, 0 si está fuera de jornada
  static int getJornadaActual() {
    final now = DateTime.now();
    final horaActual = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    if (horaActual.compareTo(horarios[manana]!['inicio']!) >= 0 &&
        horaActual.compareTo(horarios[manana]!['fin']!) < 0) {
      return 1;
    }
    if (horaActual.compareTo(horarios[tarde]!['inicio']!) >= 0 &&
        horaActual.compareTo(horarios[tarde]!['fin']!) < 0) {
      return 2;
    }
    if (horaActual.compareTo(horarios[noche]!['inicio']!) >= 0 &&
        horaActual.compareTo(horarios[noche]!['fin']!) < 0) {
      return 3;
    }
    return 0; // Fuera del horario de las jornadas
  }

  // Convierte el número de jornada (1, 2, 3) a su string correspondiente
  static String getJornadaString(int jornada) {
    switch (jornada) {
      case 1:
        return manana;
      case 2:
        return tarde;
      case 3:
        return noche;
      default:
        return '';
    }
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
