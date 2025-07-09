import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/ficha_model.dart';
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
    final futures = topFichas.map((ficha) =>
      Provider.of<AsistenciaProvider>(context, listen: false)
        .apiService
        .getCantidadAprendicesPorFicha(ficha.id)
    ).toList();

    return FutureBuilder<List<int>>(
      future: Future.wait(futures),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 220,
            child: Center(child: Icon(Icons.error, color: Colors.red)),
          );
        }
        final cantidades = snapshot.data ?? [];
        final presentes = cantidades;
        final ausentes = List.generate(cantidades.length, (i) => 0); // Puedes actualizar esto si tienes datos reales
        final maxY = (presentes + ausentes).fold<double>(0, (prev, e) => e > prev ? e.toDouble() : prev) + 2;

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
                        final color = rodIndex == 0 ? const Color(0xFF7C3AED) : const Color(0xFFF472B6);
                        return BarTooltipItem(
                          '${ficha.numeroFicha}\n',
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          children: [
                            TextSpan(
                              text: '$tipo: ${rod.toY.toInt()}',
                              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
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
                          if (idx < 0 || idx >= topFichas.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              topFichas[idx].numeroFicha.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(topFichas.length, (i) =>
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: presentes[i].toDouble(),
                          color: const Color(0xFF7C3AED),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.deepPurple.shade100, width: 1),
                          rodStackItems: [],
                          backDrawRodData: BackgroundBarChartRodData(show: false),
                        ),
                        BarChartRodData(
                          toY: ausentes[i].toDouble(),
                          color: const Color(0xFFF472B6),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.pink.shade100, width: 1),
                          rodStackItems: [],
                          backDrawRodData: BackgroundBarChartRodData(show: false),
                        ),
                      ],
                      showingTooltipIndicators: [0, 1],
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 2, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: const Color(0xFF7C3AED), label: 'Presentes'),
                const SizedBox(width: 24),
                _LegendItem(color: const Color(0xFFF472B6), label: 'Ausentes'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({Key? key, required this.color, required this.label}) : super(key: key);

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
      ],
    );
  }
} 