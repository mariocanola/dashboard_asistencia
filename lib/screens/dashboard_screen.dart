import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/asistencia_provider.dart';
import '../utils/constants.dart';
import '../models/estadisticas_model.dart';
import '../models/asistencia_model.dart';
import '../models/ficha_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedChartIndex = 0;
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AsistenciaProvider>();
      provider.cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<AsistenciaProvider>(
        builder: (context, provider, _) {
          // Obtener estadísticas de la jornada actual
          final estadisticas = provider.estadisticas[provider.jornadaActual];
          final totalAprendices = estadisticas?.totalAprendices ?? 0;
          final totalPresentes = estadisticas?.totalPresentes ?? 0;
          final totalAusentes = totalAprendices - totalPresentes;
          final porcentajeAsistencia = totalAprendices > 0 
              ? (totalPresentes / totalAprendices * 100).round() 
              : 0;

          // Formatear fecha y hora
          final fechaActual = _formatDate(DateTime.now());
          final horaActual = DateFormat('h:mm a').format(DateTime.now());
          final jornadaActual = provider.jornadaActual.isNotEmpty 
              ? provider.jornadaActual 
              : 'Fuera de jornada';

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  _buildHeader(fechaActual, horaActual, jornadaActual),
                  SizedBox(height: 24.h),
                  // Tarjetas de resumen
                  _buildSummaryCards(
                    totalFichas: provider.fichas.length,
                    totalPresentes: totalPresentes,
                    totalAusentes: totalAusentes,
                    porcentajeAsistencia: porcentajeAsistencia,
                  ),
                  // Gráfico circular de asistencia
                  SizedBox(height: 12.h),
                  _buildPieChart(estadisticas),
                  // Gráfico circular
                  // Gráficas de barras agrupadas para las fichas
                  _buildGroupedBarChart(provider.fichas),
                  SizedBox(height: 24.h),
                  // Listado de fichas
                  Text(
                    'Fichas de caracterización',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // _buildFichasList(provider.fichas), // Eliminado como se solicitó
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Formato de fecha
  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final days = [
      'Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'
    ];
    
    final weekday = days[date.weekday % 7];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    
    return '$weekday, $day de $month de $year';
  }

  // Encabezado
  Widget _buildHeader(String fecha, String hora, String jornada) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Panel de Control',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              fecha,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0EA5E9),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '$jornada • $hora',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0369A1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tarjetas de resumen
  Widget _buildSummaryCards({
    required int totalFichas,
    required int totalPresentes,
    required int totalAusentes,
    required int porcentajeAsistencia,
  }) {
    return Row(
      children: [
        _buildSummaryCard(
          'Total Fichas',
          totalFichas.toString(),
          Icons.list_alt_rounded,
          const Color(0xFF3B82F6), // Azul
        ),
        SizedBox(width: 12.w),
        _buildSummaryCard(
          'Presentes',
          totalPresentes.toString(),
          Icons.check_circle_rounded,
          const Color(0xFF10B981), // Verde
        ),
        SizedBox(width: 12.w),
        _buildSummaryCard(
          'Ausentes',
          totalAusentes.toString(),
          Icons.cancel_rounded,
          const Color(0xFFEF4444), // Rojo
        ),
      ],
    );
  }

  // Resumen de tarjeta individual
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16.w),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Gráfico Circular
  Widget _buildPieChart(EstadisticasJornada? estadisticas) {
    int totalAprendices;
    int totalPresentes;
    int totalAusentes;

    if (estadisticas == null || estadisticas.totalAprendices == 0) {
      // Datos de prueba
      totalAprendices = 15;
      totalPresentes = 10;
      totalAusentes = 5;
    } else {
      totalAprendices = estadisticas.totalAprendices;
      totalPresentes = estadisticas.totalPresentes;
      totalAusentes = totalAprendices - totalPresentes;
    }

    final List<PieChartSectionData> sections = [];

    // Sección de Presentes
    if (totalPresentes > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFF10B981),
          value: totalPresentes.toDouble(),
          title: '${(totalPresentes / totalAprendices * 100).round()}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // Sección de Ausentes
    if (totalAusentes > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFFEF4444),
          value: totalAusentes.toDouble(),
          title: '${(totalAusentes / totalAprendices * 100).round()}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedPieIndex = -1;
                      return;
                    }
                    _touchedPieIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedBarChart(List<FichaModel> fichas) {
    final topFichas = fichas.take(7).toList(); // Hasta 7 fichas para ejemplo visual
    if (topFichas.isEmpty) {
      return const SizedBox();
    }
    // Preparamos los futures para obtener la cantidad de aprendices de cada ficha
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
        // Por ahora presentes = total aprendices, ausentes = 0
        final presentes = cantidades;
        final ausentes = List.generate(cantidades.length, (i) => 0); // TODO: actualizar si tienes el dato real
        return SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (presentes + ausentes).fold<double>(0, (prev, e) => e > prev ? e.toDouble() : prev) + 2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 28),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                      color: const Color(0xFF7C3AED), // Morado
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: ausentes[i].toDouble(),
                      color: const Color(0xFFF472B6), // Rosado
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                  showingTooltipIndicators: [],
                ),
              ),
              gridData: FlGridData(show: false),
            ),
          ),
        );
      },
    );
  }
}
