import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/asistencia_provider.dart';
import '../models/ficha_model.dart';
import '../models/asistencia_model.dart';

class FichasCaracterizacionList extends StatelessWidget {
  const FichasCaracterizacionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AsistenciaProvider>(
      builder: (context, provider, _) {
        final fichasEnFormacion = _getFichasEnFormacion(provider);

        if (fichasEnFormacion.isEmpty) {
          return _buildEmptyState();
        }

        return Container(
          constraints: BoxConstraints(
            maxHeight: 400.h,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: fichasEnFormacion.length,
            itemBuilder: (context, index) {
              final fichaData = fichasEnFormacion[index];
              return _buildFichaCard(fichaData);
            },
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFichasEnFormacion(
      AsistenciaProvider provider) {
    final fichasJornadaActual = provider.fichasJornadaActual;
    final asistenciasJornadaActual = provider.asistenciasJornadaActual;

    List<Map<String, dynamic>> fichasEnFormacion = [];

    for (final ficha in fichasJornadaActual) {
      // Buscar la asistencia correspondiente a esta ficha
      final asistencia = asistenciasJornadaActual.firstWhere(
        (a) => a.ficha == ficha.numeroFicha.toString(),
        orElse: () => Asistencia(
          id: '',
          ficha: ficha.numeroFicha.toString(),
          programa: ficha.programaFormacion.nombre,
          jornada: ficha.jornadaFormacion.jornada,
          aprendicesEsperados: 0,
          aprendicesPresentes: 0,
          fechaActualizacion: DateTime.now(),
        ),
      );

      // Solo incluir fichas que tengan aprendices presentes (en formación)
      if (asistencia.aprendicesPresentes > 0) {
        fichasEnFormacion.add({
          'ficha': ficha,
          'asistencia': asistencia,
        });
      }
    }

    // Ordenar por número de ficha
    fichasEnFormacion.sort(
        (a, b) => a['ficha'].numeroFicha.compareTo(b['ficha'].numeroFicha));

    return fichasEnFormacion;
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Icon(
                Icons.school_rounded,
                size: 32.w,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No hay fichas en formación',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'No se encontraron fichas con aprendices presentes',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFichaCard(Map<String, dynamic> fichaData) {
    final ficha = fichaData['ficha'] as FichaModel;
    final asistencia = fichaData['asistencia'] as Asistencia;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de la ficha
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF1D4ED8),
                ],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.class_rounded,
              color: Colors.white,
              size: 20.w,
            ),
          ),
          SizedBox(width: 16.w),

          // Información de la ficha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ficha ${ficha.numeroFicha}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  ficha.programaFormacion.nombre,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(width: 16.w),

          // Contador de aprendices presentes
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF10B981),
                  Color(0xFF059669),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 16.w,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${asistencia.aprendicesPresentes}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
