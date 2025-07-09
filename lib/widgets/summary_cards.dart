import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'summary_card.dart';

/// Widget que muestra un conjunto de tarjetas resumen con estadísticas de asistencia
class SummaryCards extends StatelessWidget {
  final int totalFichas;
  final int totalPresentes;
  final int totalAusentes;
  final int porcentajeAsistencia;

  const SummaryCards({
    Key? key,
    required this.totalFichas,
    required this.totalPresentes,
    required this.totalAusentes,
    required this.porcentajeAsistencia,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCard(
                context: context,
                title: 'Total Fichas',
                value: totalFichas.toString(),
                icon: Icons.list_alt_rounded,
                color: const Color(0xFF3B82F6),
                isLargeScreen: isLargeScreen,
              ),
              SizedBox(width: isLargeScreen ? 16.w : 12.w),
              _buildCard(
                context: context,
                title: 'Presentes',
                value: totalPresentes.toString(),
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                isLargeScreen: isLargeScreen,
              ),
              SizedBox(width: isLargeScreen ? 16.w : 12.w),
              _buildCard(
                context: context,
                title: 'Ausentes',
                value: totalAusentes.toString(),
                icon: Icons.cancel_rounded,
                color: const Color(0xFFEF4444),
                isLargeScreen: isLargeScreen,
              ),
              if (isLargeScreen) SizedBox(width: 16.w),
              if (isLargeScreen)
                _buildCard(
                  context: context,
                  title: 'Asistencia',
                  value: '$porcentajeAsistencia%',
                  icon: Icons.percent_rounded,
                  color: const Color(0xFFF59E0B),
                  isLargeScreen: isLargeScreen,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isLargeScreen,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isLargeScreen ? 180.w : 140.w,
      child: SummaryCard(
        title: title,
        value: value,
        icon: icon,
        color: color,
        height: isLargeScreen ? 120.h : 110.h,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}