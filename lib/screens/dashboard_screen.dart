import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../providers/asistencia_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/summary_cards.dart';
import '../widgets/asistencia_pie_chart.dart';
import '../widgets/fichas_bar_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AsistenciaProvider>();
      provider.cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isUltraWide = size.width > 2500; // 4K o más
    final isLarge = size.width > 1800;

    double basePadding = isUltraWide ? 80.0 : isLarge ? 40.0 : 16.0;
    double baseFontSize = isUltraWide ? 38.0 : isLarge ? 24.0 : 14.0;
    double maxWidth = isUltraWide ? 2200 : isLarge ? 1600 : 1200;

    final estadisticas = Provider.of<AsistenciaProvider>(context).estadisticas[Provider.of<AsistenciaProvider>(context).jornadaActual];
    final totalAprendices = estadisticas?.totalAprendices ?? 0;
    final totalPresentes = estadisticas?.totalPresentes ?? 0;
    final totalAusentes = totalAprendices - totalPresentes;
    final porcentajeAsistencia = totalAprendices > 0 
        ? (totalPresentes / totalAprendices * 100).round()
        : 0;

    final fechaActual = _formatDate(DateTime.now());
    final horaActual = DateFormat('h:mm a').format(DateTime.now());
    final jornadaActual = Provider.of<AsistenciaProvider>(context).jornadaActual.isNotEmpty 
        ? Provider.of<AsistenciaProvider>(context).jornadaActual 
        : 'Fuera de jornada';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<AsistenciaProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(basePadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      DashboardHeader(
                        fecha: fechaActual,
                        hora: horaActual,
                        jornada: jornadaActual,
                      ),
                      SizedBox(height: basePadding),

                      // Summary cards section
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: maxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: SummaryCards(
                                    totalFichas: provider.fichas.length,
                                    totalPresentes: totalPresentes,
                                    totalAusentes: totalAusentes,
                                    porcentajeAsistencia: porcentajeAsistencia,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Porcentaje de Asistencia',
                                          style: TextStyle(
                                            fontSize: baseFontSize * 1.5,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF4B5563),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${porcentajeAsistencia}%',
                                                style: TextStyle(
                                                  fontSize: baseFontSize * 2.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF10B981),
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.trending_up,
                                              color: const Color(0xFF10B981),
                                              size: 24.w,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: basePadding),

                      // Charts section
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: maxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Distribución de Asistencia',
                                          style: TextStyle(
                                            fontSize: baseFontSize * 1.5,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF4B5563),
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        AsistenciaPieChart(estadisticas: estadisticas),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Asistencia por Ficha',
                                          style: TextStyle(
                                            fontSize: baseFontSize * 1.5,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF4B5563),
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        FichasBarChart(fichas: provider.fichasJornadaActual),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: basePadding),

                      // Fichas section
                      Text(
                        'Fichas de caracterización',
                        style: TextStyle(
                          fontSize: baseFontSize * 1.8,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

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
}