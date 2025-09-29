import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/ficha_model.dart';
import '../models/asistencia_model.dart';
import '../providers/asistencia_provider.dart';

class FichasBarChart extends StatelessWidget {
  final List<FichaModel> fichas;

  const FichasBarChart({Key? key, required this.fichas}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topFichas = fichas.take(7).toList();
    if (topFichas.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No hay datos de fichas para mostrar',
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
    // Usar datos de asistencias existentes en lugar de hacer llamadas API adicionales
    final asistencias = Provider.of<AsistenciaProvider>(context, listen: false)
        .asistenciasJornadaActual;
    final asistenciasData = topFichas.map((ficha) {
      final asistencia = asistencias.firstWhere(
        (a) => a.ficha == ficha.numeroFicha.toString(),
        orElse: () => Asistencia(
          id: '',
          ficha: ficha.numeroFicha.toString(),
          programa: '',
          jornada: '',
          aprendicesEsperados: 0,
          aprendicesPresentes: 0,
          fechaActualizacion: DateTime.now(),
        ),
      );
      return asistencia;
    }).toList();

    final presentes =
        asistenciasData.map((a) => a.aprendicesPresentes).toList();
    final ausentes = asistenciasData.map((a) => a.aprendicesFaltantes).toList();
    final maxY = (presentes + ausentes)
            .fold<double>(0, (prev, e) => e > prev ? e.toDouble() : prev) +
        2;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.white,
                  tooltipBorder: BorderSide(color: Colors.grey.shade300),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final ficha = topFichas[group.x.toInt()];
                    final tipo = rodIndex == 0 ? 'Presentes' : 'Ausentes';
                    final color = rodIndex == 0
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFFF472B6);
                    return BarTooltipItem(
                      '${ficha.numeroFicha}\n',
                      const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      children: [
                        TextSpan(
                          text: '$tipo: ${rod.toY.toInt()}',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= topFichas.length)
                        return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          topFichas[idx].numeroFicha.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(
                topFichas.length,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: presentes[i].toDouble(),
                      color: const Color(0xFF7C3AED),
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                          color: Colors.deepPurple.shade100, width: 1),
                      rodStackItems: [],
                      backDrawRodData: BackgroundBarChartRodData(show: false),
                    ),
                    BarChartRodData(
                      toY: ausentes[i].toDouble(),
                      color: const Color(0xFFF472B6),
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                      borderSide:
                          BorderSide(color: Colors.pink.shade100, width: 1),
                      rodStackItems: [],
                      backDrawRodData: BackgroundBarChartRodData(show: false),
                    ),
                  ],
                  showingTooltipIndicators: [0, 1],
                ),
              ),
              gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
            ),
          ),
        ),
        const SizedBox(height: 16),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: const Color(0xFF7C3AED), label: 'Presentes'),
              const SizedBox(width: 32),
              Container(
                width: 1,
                height: 30,
                color: const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 32),
              _LegendItem(color: const Color(0xFFF472B6), label: 'Ausentes'),
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

  const _LegendItem({Key? key, required this.color, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
