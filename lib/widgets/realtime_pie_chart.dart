import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/asistencia_detalle_model.dart';
import '../providers/asistencia_provider.dart';
import '../utils/constants.dart';

/// Gráfico de pie en tiempo real que se actualiza automáticamente
class RealtimePieChart extends StatelessWidget {
  const RealtimePieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AsistenciaProvider>(
      builder: (context, provider, _) {
        final asistencias = provider.asistenciasDetalle;
        
        // Calcular estadísticas en tiempo real
        final estadisticas = _calculateRealtimeStats(asistencias);
        
        return Container(
          height: 300.h,
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Título del gráfico
              Row(
                children: [
                  Icon(
                    Icons.pie_chart_rounded,
                    color: DesignConstants.primaryBlue,
                    size: 24.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Distribución de Asistencia',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: DesignConstants.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Gráfico de pie
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: _buildSections(estadisticas),
                    centerSpaceRadius: 60.r,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Leyenda
              _buildLegend(estadisticas),
            ],
          ),
        );
      },
    );
  }

  /// Calcula estadísticas en tiempo real
  Map<String, int> _calculateRealtimeStats(List<AsistenciaDetalle> asistencias) {
    final totalAprendices = asistencias.length;
    final presentes = asistencias.where((a) => a.estado == 'PRESENTE').length;
    final ausentes = totalAprendices - presentes;
    
    return {
      'total': totalAprendices,
      'presentes': presentes,
      'ausentes': ausentes,
    };
  }

  /// Construye las secciones del gráfico
  List<PieChartSectionData> _buildSections(Map<String, int> estadisticas) {
    final total = estadisticas['total']!;
    final presentes = estadisticas['presentes']!;
    final ausentes = estadisticas['ausentes']!;
    
    final List<PieChartSectionData> sections = [];
    
    // Sección de presentes
    if (presentes > 0) {
      final porcentaje = total > 0 ? (presentes / total * 100) : 0;
      sections.add(
        PieChartSectionData(
          color: DesignConstants.successGreen,
          value: presentes.toDouble(),
          title: '${porcentaje.toStringAsFixed(1)}%',
          radius: 70.r,
          titleStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    // Sección de ausentes
    if (ausentes > 0) {
      final porcentaje = total > 0 ? (ausentes / total * 100) : 0;
      sections.add(
        PieChartSectionData(
          color: DesignConstants.errorRed,
          value: ausentes.toDouble(),
          title: '${porcentaje.toStringAsFixed(1)}%',
          radius: 70.r,
          titleStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    // Si no hay datos
    if (total == 0) {
      sections.add(
        PieChartSectionData(
          color: DesignConstants.textSecondary,
          value: 1,
          title: 'Sin datos',
          radius: 70.r,
          titleStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    return sections;
  }

  /// Construye la leyenda del gráfico
  Widget _buildLegend(Map<String, int> estadisticas) {
    final total = estadisticas['total']!;
    final presentes = estadisticas['presentes']!;
    final ausentes = estadisticas['ausentes']!;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          color: DesignConstants.successGreen,
          label: 'Presentes',
          count: presentes,
          total: total,
        ),
        _buildLegendItem(
          color: DesignConstants.errorRed,
          label: 'Ausentes',
          count: ausentes,
          total: total,
        ),
      ],
    );
  }

  /// Construye un item de la leyenda
  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
    required int total,
  }) {
    final porcentaje = total > 0 ? (count / total * 100) : 0;
    
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: DesignConstants.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: DesignConstants.textPrimary,
          ),
        ),
        Text(
          '${porcentaje.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 11.sp,
            color: DesignConstants.textSecondary,
          ),
        ),
      ],
    );
  }
}
