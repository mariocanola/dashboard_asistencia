import 'package:flutter/material.dart';

/// Modelo que representa las estadísticas de una ficha
class FichaEstadisticas {
  final String ficha;
  final int totalAprendices;
  final int asistenciasEnCurso;
  final int asistenciasCompletas;
  final double porcentajeVariacion;
  final String estadoGeneral;
  final String jornada;

  const FichaEstadisticas({
    required this.ficha,
    required this.totalAprendices,
    required this.asistenciasEnCurso,
    required this.asistenciasCompletas,
    required this.porcentajeVariacion,
    required this.estadoGeneral,
    required this.jornada,
  });

  /// Crea estadísticas de ficha a partir de una lista de asistencias
  factory FichaEstadisticas.fromAsistencias({
    required String ficha,
    required List<dynamic> asistencias,
  }) {
    final totalAprendices = asistencias.length;
    final asistenciasEnCurso = asistencias.where((a) => a.isEnCurso).length;
    final asistenciasCompletas = asistencias.where((a) => a.isCompleta).length;
    
    // Por ahora, simular porcentaje de variación (en el futuro vendrá del backend)
    final porcentajeVariacion = _calcularPorcentajeVariacion(asistenciasEnCurso, totalAprendices);
    
    // Determinar estado general
    final estadoGeneral = _determinarEstadoGeneral(asistenciasEnCurso, asistenciasCompletas, totalAprendices);
    
    // Obtener jornada (asumiendo que todas las asistencias de la ficha tienen la misma jornada)
    final jornada = asistencias.isNotEmpty ? asistencias.first.jornada : '';

    return FichaEstadisticas(
      ficha: ficha,
      totalAprendices: totalAprendices,
      asistenciasEnCurso: asistenciasEnCurso,
      asistenciasCompletas: asistenciasCompletas,
      porcentajeVariacion: porcentajeVariacion,
      estadoGeneral: estadoGeneral,
      jornada: jornada,
    );
  }

  /// Calcula el porcentaje de variación (simulado por ahora)
  static double _calcularPorcentajeVariacion(int enCurso, int total) {
    if (total == 0) return 0.0;
    
    // Simular variación basada en el porcentaje de asistencias en curso
    final porcentajeActual = (enCurso / total) * 100;
    
    // Simular datos del día anterior (en el futuro vendrá del backend)
    final porcentajeAnterior = 75.0; // Valor simulado
    
    return porcentajeActual - porcentajeAnterior;
  }

  /// Determina el estado general de la ficha
  static String _determinarEstadoGeneral(int enCurso, int completas, int total) {
    if (total == 0) return 'SIN DATOS';
    
    final porcentajeCompletas = (completas / total) * 100;
    
    if (porcentajeCompletas >= 90) {
      return 'COMPLETO';
    } else if (porcentajeCompletas >= 70) {
      return 'EN CURSO';
    } else {
      return 'PENDIENTE';
    }
  }

  /// Obtiene el color del estado
  Color get estadoColor {
    switch (estadoGeneral) {
      case 'COMPLETO':
        return const Color(0xFF10B981); // Verde
      case 'EN CURSO':
        return const Color(0xFFF59E0B); // Naranja
      case 'PENDIENTE':
        return const Color(0xFFEF4444); // Rojo
      default:
        return const Color(0xFF6B7280); // Gris
    }
  }

  /// Obtiene el icono de la flecha según la variación
  IconData get flechaIcon {
    if (porcentajeVariacion > 0) {
      return Icons.keyboard_arrow_up_rounded; // Flecha arriba
    } else if (porcentajeVariacion < 0) {
      return Icons.keyboard_arrow_down_rounded; // Flecha abajo
    } else {
      return Icons.keyboard_arrow_right_rounded; // Flecha derecha
    }
  }

  /// Obtiene el color de la flecha según la variación
  Color get flechaColor {
    if (porcentajeVariacion > 0) {
      return const Color(0xFF10B981); // Verde
    } else if (porcentajeVariacion < 0) {
      return const Color(0xFFEF4444); // Rojo
    } else {
      return const Color(0xFFF59E0B); // Amarillo
    }
  }

  /// Formatea el porcentaje de variación
  String get porcentajeVariacionFormateado {
    final signo = porcentajeVariacion > 0 ? '+' : '';
    return '$signo${porcentajeVariacion.toStringAsFixed(1)}%';
  }

  @override
  String toString() {
    return 'FichaEstadisticas(ficha: $ficha, total: $totalAprendices, enCurso: $asistenciasEnCurso, completas: $asistenciasCompletas, variacion: $porcentajeVariacion%, estado: $estadoGeneral)';
  }
}
