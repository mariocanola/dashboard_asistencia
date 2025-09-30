import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/asistencia_detalle_model.dart';
import '../providers/asistencia_provider.dart';
import '../utils/constants.dart';

/// Widget que muestra estadísticas en tiempo real de manera clara
class RealtimeStatsWidget extends StatelessWidget {
  const RealtimeStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AsistenciaProvider>(
      builder: (context, provider, _) {
        final asistencias = provider.asistenciasDetalle;
        
        // Calcular estadísticas en tiempo real
        final stats = _calculateStats(asistencias);
        
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 24.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Estadísticas en Tiempo Real',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Estadísticas principales
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.group_rounded,
                      label: 'Total Aprendices',
                      value: stats['total'].toString(),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle_rounded,
                      label: 'Presentes',
                      value: stats['presentes'].toString(),
                      color: DesignConstants.successGreen,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.cancel_rounded,
                      label: 'Ausentes',
                      value: stats['ausentes'].toString(),
                      color: DesignConstants.errorRed,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              // Porcentaje de asistencia
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Porcentaje de Asistencia',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${stats['porcentaje'].toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Barra de progreso
                    Container(
                      width: 60.w,
                      height: 60.w,
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: stats['porcentaje'] / 100,
                            strokeWidth: 6,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(stats['porcentaje']),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${stats['porcentaje'].toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Información adicional
              Row(
                children: [
                  Icon(
                    Icons.update_rounded,
                    color: Colors.white.withOpacity(0.8),
                    size: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Actualizado en tiempo real',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Jornada: ${provider.jornadaActual}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Calcula las estadísticas en tiempo real
  Map<String, dynamic> _calculateStats(List<AsistenciaDetalle> asistencias) {
    final total = asistencias.length;
    final presentes = asistencias.where((a) => a.estado == 'PRESENTE').length;
    final ausentes = total - presentes;
    final porcentaje = total > 0 ? (presentes / total * 100) : 0;
    
    return {
      'total': total,
      'presentes': presentes,
      'ausentes': ausentes,
      'porcentaje': porcentaje,
    };
  }

  /// Construye una tarjeta de estadística
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24.w,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Obtiene el color de la barra de progreso según el porcentaje
  Color _getProgressColor(double porcentaje) {
    if (porcentaje >= 90) {
      return DesignConstants.successGreen;
    } else if (porcentaje >= 70) {
      return DesignConstants.warningOrange;
    } else {
      return DesignConstants.errorRed;
    }
  }
}
