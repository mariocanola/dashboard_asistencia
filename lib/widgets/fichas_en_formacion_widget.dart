import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/hybrid_asistencia_provider.dart';
import '../models/asistencia_detalle_model.dart';
import '../models/ficha_estadisticas_model.dart';
import '../utils/constants.dart';

/// Widget que muestra las fichas en formación de forma compacta
class FichasEnFormacionWidget extends StatelessWidget {
  const FichasEnFormacionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HybridAsistenciaProvider>(
      builder: (context, provider, _) {
        final asistencias = provider.asistenciasDetalle;
        final fichasJornadaActual = provider.fichasJornadaActual;

        if (provider.isLoading && asistencias.isEmpty) {
          return _buildLoadingState();
        }

        // Si no hay fichas para la jornada actual, mostrar fichas disponibles
        if (fichasJornadaActual.isEmpty) {
          return _buildNoFichasForJornada(
              provider.jornadaActual, provider.fichas);
        }

        // NO mostrar estado vacío si hay fichas de la jornada
        // Las fichas se mostrarán aunque no tengan asistencias

        // Crear estadísticas para TODAS las fichas de la jornada actual
        // Incluso las que no tienen asistencias (mostrarán 0 asistencias)
        final List<FichaEstadisticas> estadisticasFichas = [];
        
        for (var ficha in fichasJornadaActual) {
          final fichaNumero = ficha['ficha'].toString();
          
          // Buscar asistencias para esta ficha específica
          final asistenciasDeEstaFicha = asistencias
              .where((a) => a.ficha == fichaNumero)
              .toList();
          
          // Crear estadísticas (puede ser con 0 asistencias)
          estadisticasFichas.add(
            FichaEstadisticas.fromAsistencias(
              ficha: fichaNumero,
              asistencias: asistenciasDeEstaFicha, // Puede estar vacía
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

  /// Widget cuando no hay fichas para la jornada actual
  Widget _buildNoFichasForJornada(
      String jornadaActual, List<dynamic> todasLasFichas) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 32.w,
            color: const Color(0xFFF59E0B),
          ),
          SizedBox(height: 12.h),
          Text(
            'No hay fichas en $jornadaActual',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF92400E),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Fichas disponibles en el sistema:',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF92400E),
            ),
          ),
          SizedBox(height: 8.h),
          ...todasLasFichas.map((ficha) {
            final jornadaId = ficha['jornada_id'] ?? 0;
            final jornadaNombre = jornadaId == 1
                ? 'MAÑANA'
                : jornadaId == 2
                    ? 'TARDE'
                    : jornadaId == 3
                        ? 'NOCHE'
                        : 'DESCONOCIDA';
            return Container(
              margin: EdgeInsets.only(bottom: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Ficha ${ficha['ficha']} - $jornadaNombre',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF92400E),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Widget de estado que requiere autenticación
  Widget _buildAuthRequiredState() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 32.w,
              color: const Color(0xFFF59E0B),
            ),
            SizedBox(height: 12.h),
            Text(
              'Requiere autenticación',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF92400E),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Las fichas en formación requieren credenciales de acceso',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF92400E),
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
    final fichasActivas =
        fichas.where((f) => f.estadoGeneral != 'SIN DATOS').length;
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
