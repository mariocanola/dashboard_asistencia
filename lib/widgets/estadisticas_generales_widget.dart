import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/asistencia_provider.dart';
import '../models/asistencia_detalle_model.dart';
import '../services/ultra_fast_asistencias_service.dart';

/// Widget optimizado para mostrar estadísticas generales con actualización automática
/// Responde en máximo 3 segundos a eventos de NuevaAsistenciaRegistrada
class EstadisticasGeneralesWidget extends StatelessWidget {
  const EstadisticasGeneralesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AsistenciaProvider>(
      builder: (context, provider, _) {
        final asistencias = provider.asistenciasDetalle;
        
        // Calcular estadísticas en tiempo real
        final stats = _calculateStats(asistencias);
        
        return _buildStatsContainer(stats);
      },
    );
  }

  /// Calcula las estadísticas en tiempo real
  Map<String, dynamic> _calculateStats(List<AsistenciaDetalle> asistencias) {
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

    // Obtener tiempo de respuesta del servicio ultra-rápido
    final ultraFastService = UltraFastAsistenciasService();
    final responseTime = ultraFastService.getResponseTime();

    return {
      'totalFichas': totalFichas,
      'fichasEnCurso': fichasEnCurso,
      'fichasCompletas': fichasCompletas,
      'responseTime': responseTime,
    };
  }

  /// Construye el contenedor de estadísticas con animaciones
  Widget _buildStatsContainer(Map<String, dynamic> stats) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
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
              label: 'Tiempo Respuesta',
              value: stats['responseTime'],
            ),
          ),
        ],
      ),
    );
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
