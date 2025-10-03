import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/robust_asistencia_provider.dart';
import '../models/asistencia_detalle_model.dart';
import '../utils/constants.dart';

/// Widget principal KPI optimizado con el provider robusto
class RobustMainKPICardWidget extends StatelessWidget {
  const RobustMainKPICardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RobustAsistenciaProvider>(
      builder: (context, provider, _) {
        // Calcular porcentaje de asistencia
        final porcentajeAsistencia = _calculateAttendancePercentage(provider);
        
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: DesignConstants.primaryGradient,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: DesignConstants.coloredShadow(DesignConstants.primaryBlue),
          ),
          child: Column(
            children: [
              // Header con estado de conexión
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Asistencia del Día',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  _buildConnectionIndicator(provider),
                ],
              ),
              SizedBox(height: 20.h),
              
              // Porcentaje principal con animación
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Text(
                  '${porcentajeAsistencia.toStringAsFixed(1)}%',
                  key: ValueKey<double>(porcentajeAsistencia),
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              
              // Estado de asistencia
              Text(
                _getAttendanceStatus(porcentajeAsistencia),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 16.h),
              
              // Información adicional
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    icon: Icons.people,
                    label: 'Total',
                    value: provider.asistenciasDetalle.length.toString(),
                  ),
                  _buildInfoItem(
                    icon: Icons.check_circle,
                    label: 'Presentes',
                    value: _countPresent(provider).toString(),
                  ),
                  _buildInfoItem(
                    icon: Icons.cancel,
                    label: 'Ausentes',
                    value: _countAbsent(provider).toString(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Calcula el porcentaje de asistencia
  double _calculateAttendancePercentage(RobustAsistenciaProvider provider) {
    final totalAsistencias = provider.asistenciasDetalle.length;
    if (totalAsistencias == 0) return 0.0;
    
    final presentes = _countPresent(provider);
    return (presentes / totalAsistencias) * 100;
  }

  /// Cuenta aprendices presentes
  int _countPresent(RobustAsistenciaProvider provider) {
    return provider.asistenciasDetalle.where((a) => a.isEnCurso || a.isCompleta).length;
  }

  /// Cuenta aprendices ausentes
  int _countAbsent(RobustAsistenciaProvider provider) {
    return provider.asistenciasDetalle.where((a) => !a.isEnCurso && !a.isCompleta).length;
  }

  /// Obtiene el estado de asistencia
  String _getAttendanceStatus(double percentage) {
    if (percentage >= 90) return 'Excelente';
    if (percentage >= 80) return 'Bueno';
    if (percentage >= 70) return 'Regular';
    return 'Necesita Mejora';
  }

  /// Construye un elemento de información
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20.w,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// Construye el indicador de conexión
  Widget _buildConnectionIndicator(RobustAsistenciaProvider provider) {
    Color color;
    IconData icon;

    if (provider.isWebSocketConnected) {
      color = Colors.green;
      icon = Icons.wifi;
    } else if (provider.isPollingActive) {
      color = Colors.orange;
      icon = Icons.sync;
    } else {
      color = Colors.red;
      icon = Icons.wifi_off;
    }

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        icon,
        size: 16.w,
        color: color,
      ),
    );
  }
}

/// Widget de métricas optimizado con el provider robusto
class RobustMetricsCardsWidget extends StatelessWidget {
  const RobustMetricsCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RobustAsistenciaProvider>(
      builder: (context, provider, _) {
        final metrics = _calculateMetrics(provider);
        
        return Row(
          children: [
            Expanded(child: _buildMetricCard(
              title: 'Total Fichas',
              value: metrics['totalFichas'].toString(),
              icon: Icons.badge,
              gradient: DesignConstants.primaryGradient,
              color: DesignConstants.primaryBlue,
            )),
            SizedBox(width: 12.w),
            Expanded(child: _buildMetricCard(
              title: 'Presentes',
              value: metrics['presentes'].toString(),
              icon: Icons.check_circle,
              gradient: DesignConstants.successGradient,
              color: DesignConstants.successGreen,
            )),
            SizedBox(width: 12.w),
            Expanded(child: _buildMetricCard(
              title: 'Ausentes',
              value: metrics['ausentes'].toString(),
              icon: Icons.cancel,
              gradient: DesignConstants.errorGradient,
              color: DesignConstants.errorRed,
            )),
            SizedBox(width: 12.w),
            Expanded(child: _buildMetricCard(
              title: 'Jornada',
              value: metrics['jornada'],
              icon: Icons.schedule,
              gradient: DesignConstants.purpleGradient,
              color: DesignConstants.purple,
            )),
          ],
        );
      },
    );
  }

  /// Calcula las métricas
  Map<String, dynamic> _calculateMetrics(RobustAsistenciaProvider provider) {
    final asistencias = provider.asistenciasDetalle;
    
    // Agrupar por ficha
    final Map<String, List<AsistenciaDetalle>> porFicha = {};
    for (var asistencia in asistencias) {
      porFicha.putIfAbsent(asistencia.ficha, () => []).add(asistencia);
    }

    final totalFichas = porFicha.length;
    final presentes = asistencias.where((a) => a.isEnCurso || a.isCompleta).length;
    final ausentes = asistencias.where((a) => !a.isEnCurso && !a.isCompleta).length;
    
    // Obtener jornada actual
    final jornadaActual = JornadaConstants.getJornadaString(JornadaConstants.getJornadaActual());
    
    return {
      'totalFichas': totalFichas,
      'presentes': presentes,
      'ausentes': ausentes,
      'jornada': jornadaActual.isEmpty ? 'Fuera de Jornada' : jornadaActual,
    };
  }

  /// Construye una tarjeta de métrica
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required LinearGradient gradient,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: DesignConstants.coloredShadow(color),
      ),
      child: Column(
        children: [
          // Icono
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Valor con animación
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Text(
              value,
              key: ValueKey<String>(value),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 4.h),
          
          // Título
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget de estadísticas generales optimizado con el provider robusto
class RobustEstadisticasGeneralesWidget extends StatelessWidget {
  const RobustEstadisticasGeneralesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RobustAsistenciaProvider>(
      builder: (context, provider, _) {
        final stats = _calculateStats(provider);
        
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: DesignConstants.primaryGradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: DesignConstants.coloredShadow(DesignConstants.primaryBlue),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildAnimatedStatItem(
                  icon: Icons.badge_rounded,
                  label: 'Total Fichas',
                  value: stats['totalFichas'].toString(),
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildAnimatedStatItem(
                  icon: Icons.pending_actions_rounded,
                  label: 'Con En Curso',
                  value: stats['fichasEnCurso'].toString(),
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildAnimatedStatItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Con Completas',
                  value: stats['fichasCompletas'].toString(),
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildAnimatedStatItem(
                  icon: Icons.speed_rounded,
                  label: 'Estado',
                  value: _getConnectionStatus(provider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Calcula las estadísticas
  Map<String, dynamic> _calculateStats(RobustAsistenciaProvider provider) {
    final asistencias = provider.asistenciasDetalle;
    
    // Agrupar por ficha
    final Map<String, List<AsistenciaDetalle>> porFicha = {};
    for (var asistencia in asistencias) {
      porFicha.putIfAbsent(asistencia.ficha, () => []).add(asistencia);
    }

    final totalFichas = porFicha.length;
    
    // Contar fichas con diferentes estados
    int fichasEnCurso = 0;
    int fichasCompletas = 0;
    
    for (var fichaAsistencias in porFicha.values) {
      final tieneEnCurso = fichaAsistencias.any((a) => a.isEnCurso);
      final tieneCompletas = fichaAsistencias.any((a) => a.isCompleta);
      
      if (tieneEnCurso) fichasEnCurso++;
      if (tieneCompletas) fichasCompletas++;
    }

    return {
      'totalFichas': totalFichas,
      'fichasEnCurso': fichasEnCurso,
      'fichasCompletas': fichasCompletas,
    };
  }

  /// Obtiene el estado de conexión
  String _getConnectionStatus(RobustAsistenciaProvider provider) {
    if (provider.isWebSocketConnected) {
      return 'WS';
    } else if (provider.isPollingActive) {
      return 'POLL';
    } else {
      return 'OFF';
    }
  }

  /// Construye un elemento de estadística con animación
  Widget _buildAnimatedStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono con animación
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20.w,
          ),
        ),
        SizedBox(height: 8.h),
        
        // Valor con animación
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Text(
            value,
            key: ValueKey<String>(value),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 4.h),
        
        // Etiqueta
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
