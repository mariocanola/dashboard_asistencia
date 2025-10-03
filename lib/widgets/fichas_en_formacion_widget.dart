import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/asistencia_provider.dart';
import '../models/asistencia_detalle_model.dart';
import '../models/ficha_estadisticas_model.dart';
import '../utils/constants.dart';

/// Widget que muestra las fichas en formación de forma compacta
class FichasEnFormacionWidget extends StatelessWidget {
  const FichasEnFormacionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AsistenciaProvider>(
      builder: (context, provider, _) {
        final asistencias = provider.asistenciasDetalle;

        if (provider.isLoading && asistencias.isEmpty) {
          return _buildLoadingState();
        }

        if (asistencias.isEmpty) {
          return _buildEmptyState();
        }

        // Agrupar asistencias por ficha
        final Map<String, List<AsistenciaDetalle>> porFicha = {};
        for (var asistencia in asistencias) {
          if (!porFicha.containsKey(asistencia.ficha)) {
            porFicha[asistencia.ficha] = [];
          }
          porFicha[asistencia.ficha]!.add(asistencia);
        }

        // Crear estadísticas para cada ficha
        final List<FichaEstadisticas> estadisticasFichas = [];
        for (var entry in porFicha.entries) {
          estadisticasFichas.add(
            FichaEstadisticas.fromAsistencias(
              ficha: entry.key,
              asistencias: entry.value,
            ),
          );
        }

        return Column(
          children: [
            // Resumen compacto de fichas
            _buildResumenFichas(estadisticasFichas),
            SizedBox(height: 16.h),

            // Lista de fichas
            ...estadisticasFichas.map((estadistica) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildFichaCard(estadistica),
              );
            }),
          ],
        );
      },
    );
  }

  /// Widget de estado de carga
  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DesignConstants.primaryBlue,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Cargando fichas...',
              style: TextStyle(
                fontSize: 12.sp,
                color: DesignConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de estado vacío
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 32.w,
              color: DesignConstants.textSecondary,
            ),
            SizedBox(height: 12.h),
            Text(
              'No hay fichas activas',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: DesignConstants.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Las fichas aparecerán aquí cuando estén activas',
              style: TextStyle(
                fontSize: 12.sp,
                color: DesignConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de resumen compacto de fichas
  Widget _buildResumenFichas(List<FichaEstadisticas> fichas) {
    final totalFichas = fichas.length;
    final fichasActivas = fichas.where((f) => f.estadoGeneral != 'SIN DATOS').length;
    final totalAprendices = fichas.fold(0, (sum, f) => sum + f.totalAprendices);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.school_rounded,
              label: 'Fichas',
              value: totalFichas.toString(),
            ),
          ),
          Container(
            width: 1,
            height: 30.h,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.people_rounded,
              label: 'Aprendices',
              value: totalAprendices.toString(),
            ),
          ),
          Container(
            width: 1,
            height: 30.h,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_rounded,
              label: 'Activas',
              value: fichasActivas.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 16.w,
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
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Widget de card de ficha compacta
  Widget _buildFichaCard(FichaEstadisticas estadistica) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de ficha
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: DesignConstants.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              Icons.badge_rounded,
              color: DesignConstants.primaryBlue,
              size: 16.w,
            ),
          ),
          SizedBox(width: 10.w),

          // Información de la ficha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ficha ${estadistica.ficha}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: DesignConstants.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${estadistica.totalAprendices} aprendices',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: DesignConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Porcentaje de variación con flecha
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: estadistica.flechaColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  estadistica.flechaIcon,
                  color: estadistica.flechaColor,
                  size: 12.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  estadistica.porcentajeVariacionFormateado,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: estadistica.flechaColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // Estado general
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: estadistica.estadoColor,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              estadistica.estadoGeneral,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
