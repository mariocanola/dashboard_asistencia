import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/hybrid_asistencia_provider.dart';

/// Widget para mostrar el KPI principal de asistencia
class MainKPICardWidget extends StatelessWidget {
  final double baseFontSize;
  
  const MainKPICardWidget({
    super.key,
    required this.baseFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HybridAsistenciaProvider>(
      builder: (context, provider, _) {
        final porcentaje = provider.kpiAsistenciaPorcentaje;
        
        return SizedBox(
          width: double.infinity,
          child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Asistencia del Día',
                style: TextStyle(
                  fontSize: baseFontSize * 1.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              
              // Porcentaje principal
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    porcentaje?.toStringAsFixed(1) ?? '--',
                    style: TextStyle(
                      fontSize: baseFontSize * 4,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
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
                        fontSize: baseFontSize * 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Badge de estado
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sentiment_very_satisfied_rounded,
                      color: Colors.white,
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Excelente',
                      style: TextStyle(
                        fontSize: baseFontSize * 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}