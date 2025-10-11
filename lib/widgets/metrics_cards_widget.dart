import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/hybrid_asistencia_provider.dart';

/// Widget optimizado para mostrar las tarjetas de métricas
/// Solo se reconstruye cuando cambian los datos específicos de las métricas
/// Consume datos pre-calculados del HybridAsistenciaProvider
class MetricsCardsWidget extends StatelessWidget {
  final double baseFontSize;

  const MetricsCardsWidget({
    super.key,
    required this.baseFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HybridAsistenciaProvider>(
      builder: (context, provider, _) {
        // Obtener métricas pre-calculadas del provider
        final totalFichas = provider.totalFichas;
        final totalPresentes = provider.presentes;
        final totalAusentes = provider.ausentes;
        final jornada = provider.jornadaActual;

        // Debug: Mostrar métricas actualizadas
        debugPrint(
          '📊 MetricsCards - Fichas: $totalFichas | Presentes: $totalPresentes | Ausentes: $totalAusentes | Jornada: $jornada',
        );

        return Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'Total Fichas',
                value: totalFichas.toString(),
                icon: Icons.assignment_rounded,
                color: const Color(0xFF3B82F6),
                baseFontSize: baseFontSize,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'Presentes',
                value: totalPresentes.toString(),
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                baseFontSize: baseFontSize,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'Ausentes',
                value: totalAusentes.toString(),
                icon: Icons.cancel_rounded,
                color: const Color(0xFFEF4444),
                baseFontSize: baseFontSize,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'Jornada',
                value: jornada,
                icon: Icons.schedule_rounded,
                color: const Color(0xFF8B5CF6),
                baseFontSize: baseFontSize,
                isTextValue: true,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Construye una tarjeta de métrica moderna y elegante
  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double baseFontSize,
    bool isTextValue = false,
  }) {
    // Definir gradientes sutiles para cada tipo de card
    LinearGradient cardGradient;
    switch (color.value) {
      case 0xFF3B82F6: // Azul - Total Fichas
        cardGradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F7FF), Color(0xFFE6F2FF)],
        );
        break;
      case 0xFF10B981: // Verde - Presentes
        cardGradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FDF4), Color(0xFFE6FFED)],
        );
        break;
      case 0xFFEF4444: // Rojo - Ausentes
        cardGradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF5F5), Color(0xFFFFEBEB)],
        );
        break;
      case 0xFF8B5CF6: // Morado - Jornada
        cardGradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F5FF), Color(0xFFF0EBFF)],
        );
        break;
      default:
        cardGradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
        );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono con fondo circular moderno
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.w,
            ),
          ),
          SizedBox(height: 12.h),
          // Valor principal con animación
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value,
              key: ValueKey(value),
              style: TextStyle(
                fontSize: isTextValue ? baseFontSize * 1.3 : baseFontSize * 2.2,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 6.h),
          // Título elegante
          Text(
            title,
            style: TextStyle(
              fontSize: baseFontSize * 0.9,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
