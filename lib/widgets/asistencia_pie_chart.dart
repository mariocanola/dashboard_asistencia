import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/estadisticas_model.dart';

class AsistenciaPieChart extends StatelessWidget {
  final EstadisticasJornada? estadisticas;

  const AsistenciaPieChart({Key? key, required this.estadisticas}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalAprendices;
    int totalPresentes;
    int totalAusentes;

    if (estadisticas == null || estadisticas!.totalAprendices == 0) {
      totalAprendices = 1;
      totalPresentes = 2;
      totalAusentes = 3;
    } else {
      totalAprendices = estadisticas!.totalAprendices;
      totalPresentes = estadisticas!.totalPresentes;
      totalAusentes = totalAprendices - totalPresentes;
    }

    final double porcentajePresentes = totalAprendices > 0 ? (totalPresentes / totalAprendices * 100) : 0;
    final double porcentajeAusentes = totalAprendices > 0 ? (totalAusentes / totalAprendices * 100) : 0;

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
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(
              color: const Color(0xFF10B981),
              label: 'Presentes',
              value: '$totalPresentes',
              percent: '${porcentajePresentes.toStringAsFixed(1)}%',
            ),
            const SizedBox(width: 24),
            _LegendItem(
              color: const Color(0xFFEF4444),
              label: 'Ausentes',
              value: '$totalAusentes',
              percent: '${porcentajeAusentes.toStringAsFixed(1)}%',
            ),
          ],
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
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(width: 4),
        Text(
          '($percent)',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }
} 