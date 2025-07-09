import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/asistencia_provider.dart';
import '../utils/constants.dart';
import '../models/estadisticas_model.dart';
import '../models/asistencia_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedChartIndex = 0;
  int _touchedPieIndex = -1;
  final List<String> _chartTypes = ['General', 'Por Programa', 'Detallado'];
  
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
                    totalFichas: estadisticas?.programas.length ?? 0,
                    totalPresentes: totalPresentes,
                    totalAusentes: totalAusentes,
                    porcentajeAsistencia: porcentajeAsistencia,
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Selector de gráficos
                  _buildChartSelector(),
                  
                  SizedBox(height: 24.h),
                  
                  // Gráfico seleccionado
                  _buildSelectedChart(estadisticas, provider.jornadaActual),
                  
                  SizedBox(height: 24.h),
                  
                  // Lista de fichas
                  _buildFichasList(estadisticas),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Widgets auxiliares
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
          const Color(0xFF3B82F6),
        ),
        SizedBox(width: 12.w),
        _buildSummaryCard(
          'Presentes',
          totalPresentes.toString(),
          Icons.check_circle_rounded,
          const Color(0xFF10B981),
        ),
        SizedBox(width: 12.w),
        _buildSummaryCard(
          'Ausentes',
          totalAusentes.toString(),
          Icons.cancel_rounded,
          const Color(0xFFEF4444),
        ),
      ],
    );
  }
  
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
  
  Widget _buildChartSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_chartTypes.length, (index) {
          final isSelected = _selectedChartIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedChartIndex = index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _chartTypes[index],
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildSelectedChart([EstadisticasJornada? estadisticas, String jornada = '']) {
    if (estadisticas == null) {
      return Container(
        height: 300.h,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    
    switch (_selectedChartIndex) {
      case 0:
        return _buildPieChart(estadisticas);
      case 1:
        return _buildBarChart(estadisticas);
      case 2:
        return _buildDetailedChart(estadisticas);
      default:
        return _buildPieChart(estadisticas);
    }
  }
  
  Widget _buildPieChart(EstadisticasJornada estadisticas) {
    final totalAprendices = estadisticas.totalAprendices;
    final totalPresentes = estadisticas.totalPresentes;
    final totalAusentes = totalAprendices - totalPresentes;
    
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
        SizedBox(height: 16.h),
        _buildPieChartLegend(estadisticas),
      ],
    );
  }
  
  Widget _buildPieChartLegend(EstadisticasJornada estadisticas) {
    final totalAprendices = estadisticas.totalAprendices;
    final totalPresentes = estadisticas.totalPresentes;
    final totalAusentes = totalAprendices - totalPresentes;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          'Presentes',
          const Color(0xFF10B981),
          totalPresentes,
          totalAprendices,
        ),
        SizedBox(width: 24.w),
        _buildLegendItem(
          'Ausentes',
          const Color(0xFFEF4444),
          totalAusentes,
          totalAprendices,
        ),
      ],
    );
  }
  
  Widget _buildLegendItem(String label, Color color, int value, int total) {
    final percentage = total > 0 ? (value / total * 100).round() : 0;
    
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '$value ($percentage%)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBarChart(EstadisticasJornada estadisticas) {
    final programas = estadisticas.programas;
    if (programas.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }
    
    // Tomar hasta 5 programas para mejor visualización
    final displayedProgramas = programas.length > 5
        ? programas.sublist(0, 5)
        : programas;
    
    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final programa = displayedProgramas[groupIndex];
                    return BarTooltipItem(
                      '${programa.nombre}\n${rod.toY.round()}%',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < displayedProgramas.length) {
                        final nombre = displayedProgramas[value.toInt()].nombre;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            nombre.length > 8
                                ? '${nombre.substring(0, 8)}..'
                                : nombre,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 40,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: const Color(0xFFE2E8F0),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: displayedProgramas.asMap().entries.map((entry) {
                final index = entry.key;
                final programa = entry.value;
                final porcentaje = programa.porcentajeAsistencia.toDouble();
                
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: porcentaje,
                      color: _getColorForPercentage(porcentaje),
                      width: 24.w,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Asistencia por Programa',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailedChart(EstadisticasJornada estadisticas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalle por Programa',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 16.h),
        ...estadisticas.programas.map((programa) {
          final porcentaje = programa.porcentajeAsistencia.toDouble();
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      programa.nombre,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${porcentaje.round()}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: _getColorForPercentage(porcentaje),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Stack(
                  children: [
                    Container(
                      height: 8.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 8.h,
                      width: MediaQuery.of(context).size.width * (porcentaje / 100) * 0.9,
                      decoration: BoxDecoration(
                        color: _getColorForPercentage(porcentaje),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${programa.aprendicesPresentes} de ${programa.aprendicesEsperados} aprendices',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    Text(
                      '${programa.aprendicesFaltantes} faltantes',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildFichasList(EstadisticasJornada? estadisticas) {
    if (estadisticas == null || estadisticas.programas.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Aplanar la lista de fichas de todos los programas
    final List<MapEntry<String, int>> fichas = [];
    
    for (final programa in estadisticas.programas) {
      for (final ficha in programa.fichas) {
        // Usar el porcentaje de asistencia del programa como aproximación
        final porcentaje = programa.porcentajeAsistencia.toInt();
        fichas.add(MapEntry(ficha, porcentaje));
      }
    }
    
    if (fichas.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado por Ficha',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.5,
          ),
          itemCount: fichas.length,
          itemBuilder: (context, index) {
            final ficha = fichas[index];
            return _buildFichaCard(ficha.key, ficha.value);
          },
        ),
      ],
    );
  }
  
  Widget _buildFichaCard(String ficha, int porcentaje) {
    return Container(
      padding: EdgeInsets.all(12.w),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            ficha,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$porcentaje%',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: _getColorForPercentage(porcentaje.toDouble()),
            ),
          ),
          Stack(
            children: [
              Container(
                height: 6.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 6.h,
                width: double.infinity * (porcentaje / 100),
                decoration: BoxDecoration(
                  color: _getColorForPercentage(porcentaje.toDouble()),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getColorForPercentage(double percentage) {
    if (percentage >= 90) return const Color(0xFF10B981); // Verde
    if (percentage >= 70) return const Color(0xFF3B82F6); // Azul
    if (percentage >= 50) return const Color(0xFFF59E0B); // Ámbar
    return const Color(0xFFEF4444); // Rojo
  }
}
