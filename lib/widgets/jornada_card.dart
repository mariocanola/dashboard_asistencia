import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/constants.dart';

class JornadaCard extends StatelessWidget {
  final String jornada;
  final String horario;
  final int totalAprendices;
  final int aprendicesPresentes;
  final bool activa;

  const JornadaCard({
    super.key,
    required this.jornada,
    required this.horario,
    required this.totalAprendices,
    required this.aprendicesPresentes,
    this.activa = false,
  });

  @override
  Widget build(BuildContext context) {
    final aprendicesFaltantes = totalAprendices - aprendicesPresentes;
    final porcentaje = totalAprendices > 0 
        ? (aprendicesPresentes / totalAprendices * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: activa 
              ? Color(AppThemes.primaryColor) 
              : Colors.grey.shade300,
          width: activa ? 2.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la tarjeta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                jornada.toUpperCase(),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(AppThemes.primaryColor),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: activa 
                      ? Color(AppThemes.primaryColor).withOpacity(0.1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  horario,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: activa 
                        ? Color(AppThemes.primaryColor) 
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Indicador de progreso
          Stack(
            children: [
              // Fondo de la barra de progreso
              Container(
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              // Barra de progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 24.h,
                  width: (MediaQuery.of(context).size.width - 144.w) * 
                         (totalAprendices > 0 ? aprendicesPresentes / totalAprendices : 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(AppThemes.primaryColor),
                        Color(AppThemes.secondaryColor),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // Porcentaje
              Positioned.fill(
                child: Center(
                  child: Text(
                    '$porcentaje%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Estadísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'TOTAL',
                '$totalAprendices',
                Colors.blue.shade700,
              ),
              _buildStatItem(
                'PRESENTES',
                '$aprendicesPresentes',
                Colors.green.shade700,
              ),
              _buildStatItem(
                'FALTANTES',
                '$aprendicesFaltantes',
                Colors.red.shade700,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
