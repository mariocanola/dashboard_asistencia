import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/asistencia_provider.dart';

/// Widget optimizado para mostrar el KPI principal de asistencia
/// Solo se reconstruye cuando cambian los datos de asistencia
class MainKPICardWidget extends StatelessWidget {
  final double baseFontSize;

  const MainKPICardWidget({
    super.key,
    required this.baseFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AsistenciaProvider>(
      builder: (context, provider, _) {
        // Calcular métricas basadas en datos reales disponibles
        final asistenciasDetalle = provider.asistenciasDetalle;
        
        // Debug: Mostrar información de las asistencias
        debugPrint('🔄 MainKPI - Recalculando porcentaje: ${asistenciasDetalle.length} asistencias');

        // Calcular fichas únicas desde las asistencias
        final fichasUnicas = asistenciasDetalle.map((a) => a.ficha).toSet();
        
        // Calcular aprendices únicos por ficha desde asistenciasDetalle
        final Map<String, Set<String>> aprendicesPorFicha = {};
        for (var asistencia in asistenciasDetalle) {
          aprendicesPorFicha.putIfAbsent(asistencia.ficha, () => <String>{}).add(asistencia.numeroDocumento);
        }
        
        // Calcular totales
        int totalAprendicesEsperados = 0;
        int totalPresentes = 0;
        
        // Para cada ficha única, calcular aprendices esperados y presentes
        for (var fichaStr in fichasUnicas) {
          final aprendicesEnFicha = aprendicesPorFicha[fichaStr]?.length ?? 0;
          
          // Asumir que cada ficha tiene un número esperado de aprendices
          // En el futuro esto debería venir del modelo FichaModel
          final aprendicesEsperadosPorFicha = 20; // Valor por defecto
          
          totalAprendicesEsperados += aprendicesEsperadosPorFicha;
          totalPresentes += aprendicesEnFicha;
        }
        
        // Calcular porcentaje de asistencia
        final porcentajeAsistencia = totalAprendicesEsperados > 0
            ? (totalPresentes / totalAprendicesEsperados * 100).round()
            : 0;

        debugPrint(
          '🔄 MainKPI - Porcentaje actualizado: $porcentajeAsistencia% (Presentes: $totalPresentes, Esperados: $totalAprendicesEsperados)',
        );

        return Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF10B981),
                Color(0xFF059669),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono principal
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 12.w),
              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asistencia del Día',
                      style: TextStyle(
                        fontSize: baseFontSize * 1.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Porcentaje con animación
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            '$porcentajeAsistencia',
                            key: ValueKey(porcentajeAsistencia),
                            style: TextStyle(
                              fontSize: baseFontSize * 3.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 4.w,
                            bottom: 8.h,
                          ),
                          child: Text(
                            '%',
                            style: TextStyle(
                              fontSize: baseFontSize * 1.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
