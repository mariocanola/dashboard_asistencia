import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/estadisticas_model.dart';

class AsistenciaPieChart extends StatelessWidget {
  final EstadisticasJornada? estadisticas;

  const AsistenciaPieChart({Key? key, required this.estadisticas})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalAprendices;
    int totalPresentes;
    int totalAusentes;

    if (estadisticas == null || estadisticas!.totalAprendices == 0) {
      totalAprendices = 0;
      totalPresentes = 0;
      totalAusentes = 0;
    } else {
      totalAprendices = estadisticas!.totalAprendices;
      totalPresentes = estadisticas!.totalPresentes;
      totalAusentes = totalAprendices - totalPresentes;
    }

    final double porcentajePresentes =
        totalAprendices > 0 ? (totalPresentes / totalAprendices * 100) : 0;
    final double porcentajeAusentes =
        totalAprendices > 0 ? (totalAusentes / totalAprendices * 100) : 0;

    final List<PieChartSectionData> sections = [
      if (totalPresentes > 0)
        PieChartSectionData(
          color: const Color(0xFF10B981),
          value: totalPresentes.toDouble(),
          title: '${porcentajePresentes.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (totalAusentes > 0)
        PieChartSectionData(
          color: const Color(0xFFEF4444),
          value: totalAusentes.toDouble(),
          title: '${porcentajeAusentes.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];

    if (totalAprendices == 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No hay datos de asistencia para mostrar',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 4,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  // Agregar interactividad si es necesario
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(
                color: const Color(0xFF10B981),
                label: 'Presentes',
                value: '$totalPresentes',
                percent: '${porcentajePresentes.toStringAsFixed(1)}%',
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFE2E8F0),
              ),
              _LegendItem(
                color: const Color(0xFFEF4444),
                label: 'Ausentes',
                value: '$totalAusentes',
                percent: '${porcentajeAusentes.toStringAsFixed(1)}%',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String percent;

  const _LegendItem({
    Key? key,
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1F2937),
          ),
        ),
        Text(
          percent,
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
