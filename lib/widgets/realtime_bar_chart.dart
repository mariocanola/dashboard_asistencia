import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/asistencia_detalle_model.dart';
import '../providers/asistencia_provider.dart';
import '../utils/constants.dart';

/// Gráfico de barras en tiempo real que se actualiza automáticamente
class RealtimeBarChart extends StatelessWidget {
  const RealtimeBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AsistenciaProvider>(
      builder: (context, provider, _) {
        final asistencias = provider.asistenciasDetalle;
        
        // Agrupar por ficha
        final fichasData = _groupByFicha(asistencias);
        
        return Container(
          height: 300.h,
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Título del gráfico
              Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    color: DesignConstants.primaryBlue,
                    size: 24.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Asistencia por Ficha',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: DesignConstants.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Gráfico de barras
              Expanded(
                child: fichasData.isEmpty 
                  ? _buildEmptyState()
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(fichasData),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.black87,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final ficha = fichasData[groupIndex];
                              return BarTooltipItem(
                                '${ficha['ficha']}\nPresentes: ${ficha['presentes']}\nAusentes: ${ficha['ausentes']}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                if (value.toInt() < fichasData.length) {
                                  final ficha = fichasData[value.toInt()];
                                  return Text(
                                    ficha['ficha'],
                                    style: TextStyle(
                                      color: DesignConstants.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 42.h,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40.w,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                if (value == meta.max) {
                                  return const Text('');
                                }
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: DesignConstants.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: _buildBarGroups(fichasData),
                      ),
                    ),
              ),
              
              SizedBox(height: 16.h),
              
              // Leyenda
              _buildLegend(),
            ],
          ),
        );
      },
    );
  }

  /// Agrupa las asistencias por ficha
  List<Map<String, dynamic>> _groupByFicha(List<AsistenciaDetalle> asistencias) {
    final Map<String, List<AsistenciaDetalle>> grouped = {};
    
    for (var asistencia in asistencias) {
      final ficha = asistencia.ficha;
      if (!grouped.containsKey(ficha)) {
        grouped[ficha] = [];
      }
      grouped[ficha]!.add(asistencia);
    }
    
    // Convertir a lista de datos
    return grouped.entries.map((entry) {
      final ficha = entry.key;
      final asistenciasFicha = entry.value;
      final total = asistenciasFicha.length;
      final presentes = asistenciasFicha.where((a) => a.estado == 'PRESENTE').length;
      final ausentes = total - presentes;
      
      return {
        'ficha': ficha,
        'total': total,
        'presentes': presentes,
        'ausentes': ausentes,
      };
    }).toList();
  }

  /// Obtiene el valor máximo del eje Y
  double _getMaxY(List<Map<String, dynamic>> fichasData) {
    if (fichasData.isEmpty) return 10;
    
    final maxTotal = fichasData
        .map((f) => f['total'] as int)
        .reduce((a, b) => a > b ? a : b);
    
    // Redondear hacia arriba al siguiente múltiplo de 5
    return ((maxTotal / 5).ceil() * 5).toDouble();
  }

  /// Construye los grupos de barras
  List<BarChartGroupData> _buildBarGroups(List<Map<String, dynamic>> fichasData) {
    return fichasData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (data['presentes'] as int).toDouble(),
            color: DesignConstants.successGreen,
            width: 16.w,
            borderRadius: BorderRadius.circular(4.r),
          ),
          BarChartRodData(
            toY: (data['ausentes'] as int).toDouble(),
            color: DesignConstants.errorRed,
            width: 16.w,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
        showingTooltipIndicators: [],
      );
    }).toList();
  }

  /// Construye la leyenda
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          color: DesignConstants.successGreen,
          label: 'Presentes',
        ),
        SizedBox(width: 24.w),
        _buildLegendItem(
          color: DesignConstants.errorRed,
          label: 'Ausentes',
        ),
      ],
    );
  }

  /// Construye un item de la leyenda
  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
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
    );
  }

  /// Estado vacío cuando no hay datos
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 48.w,
            color: DesignConstants.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No hay datos disponibles',
            style: TextStyle(
              fontSize: 14.sp,
              color: DesignConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
