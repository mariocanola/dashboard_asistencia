import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/asistencia_model.dart';
import '../providers/asistencia_provider.dart';
import 'estadisticas_card.dart';

class ListaFichasWidget extends StatelessWidget {
  const ListaFichasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AsistenciaProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const EstadisticasCard(
            titulo: 'Fichas',
            child: LoadingIndicator(),
          );
        }

        if (provider.hasError) {
          return EstadisticasCard(
            titulo: 'Fichas',
            child: ErrorMessage(
              mensaje: 'Error al cargar las fichas: ${provider.errorMessage}',
              onReintentar: provider.cargarDatos,
            ),
          );
        }

        final asistencias = provider.asistencias;
        
        if (asistencias.isEmpty) {
          return const EstadisticasCard(
            titulo: 'Fichas',
            child: Center(
              child: Text('No hay fichas disponibles para esta jornada'),
            ),
          );
        }

        return EstadisticasCard(
          titulo: 'Fichas (${asistencias.length})',
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: asistencias.length,
            separatorBuilder: (_, __) => Divider(height: 1.h, thickness: 1),
            itemBuilder: (context, index) {
              final asistencia = asistencias[index];
              return _FichaItem(asistencia: asistencia);
            },
          ),
        );
      },
    );
  }
}

class _FichaItem extends StatelessWidget {
  final Asistencia asistencia;

  const _FichaItem({required this.asistencia});

  @override
  Widget build(BuildContext context) {
    final porcentaje = asistencia.porcentajeAsistencia;
    final color = _getColorPorPorcentaje(porcentaje);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: color,
            width: 4.w,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ficha y programa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FICHA: ${asistencia.ficha}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  '${porcentaje.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 4.h),
          
          Text(
            asistencia.programa,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
          
          SizedBox(height: 8.h),
          
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: porcentaje / 100,
              minHeight: 8.h,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          
          SizedBox(height: 8.h),
          
          // Estadísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                '${asistencia.aprendicesPresentes}',
                'Presentes',
                Colors.green,
              ),
              _buildStatItem(
                '${asistencia.aprendicesFaltantes}',
                'Faltantes',
                Colors.red,
              ),
              _buildStatItem(
                '${asistencia.aprendicesEsperados}',
                'Total',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getColorPorPorcentaje(double porcentaje) {
    if (porcentaje >= 90) return Colors.green;
    if (porcentaje >= 70) return Colors.lightGreen;
    if (porcentaje >= 50) return Colors.orange;
    return Colors.red;
  }
  
  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
