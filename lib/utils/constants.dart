import 'package:flutter/material.dart';

class ApiConstants {
  /// URL base de la API
  /// Cambia esta IP por la correcta de tu servidor
  static const String baseUrl = 'http://192.168.100.79:8000/api';

  /// Endpoints de asistencias (según README backend)
  static const String asistenciaEntrada = '/asistencia/entrada';
  static const String asistenciaSalida = '/asistencia/salida';
  static const String asistenciaJornada = '/asistencia/jornada';
  static const String asistenciaFichas = '/asistencia/fichas';

  /// Endpoints anteriores (mantener para compatibilidad si es necesario)
  static const String asistencias = '/asistencias';
  static const String fichas = '/fichas-caracterizacion';
  static const String aprendicesPorFicha = '/fichas-caracterizacion/aprendices';
  static const String jornada = '/fichas-caracterizacion/jornada';

  /// Tiempo de actualización en segundos
  static const int refreshTime = 30;
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
    final horaActual =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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

class DesignConstants {
  /// Colores del nuevo diseño
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenDark = Color(0xFF059669);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color warningOrangeDark = Color(0xFFD97706);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedDark = Color(0xFFDC2626);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleDark = Color(0xFF7C3AED);
  static const Color cyan = Color(0xFF0EA5E9);
  static const Color cyanDark = Color(0xFF0284C7);

  /// Colores neutros
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color backgroundLightSecondary = Color(0xFFE2E8F0);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF475569);
  static const Color borderLight = Color(0xFFE2E8F0);

  /// Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueDark],
  );
  static const LinearGradient successGradient = LinearGradient(
    colors: [successGreen, successGreenDark],
  );
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warningOrange, warningOrangeDark],
  );
  static const LinearGradient errorGradient = LinearGradient(
    colors: [errorRed, errorRedDark],
  );
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [purple, purpleDark],
  );
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [cyan, cyanDark],
  );

  /// Sombras
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> coloredShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ];

  /// Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
}
