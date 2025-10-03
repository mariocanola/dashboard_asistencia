import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../providers/asistencia_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/ultra_fast_asistencias_widget.dart';
import '../widgets/fichas_en_formacion_widget.dart';

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
    final width = size.width;

    // Breakpoints responsivos para diferentes tipos de pantalla
    final isTV = width > 3840; // 4K TV y superiores
    final isUltraWide = width > 2500; // Monitores ultra wide
    final isLargeDesktop = width > 1800; // Desktop grande
    final isDesktop = width > 1200; // Desktop estándar
    final isTablet = width > 768; // Tablet
    final isMobile = width <= 768; // Móvil

    // Padding responsivo - Más generoso para mejor respiración visual
    double basePadding = isTV
        ? 140.0
        : isUltraWide
            ? 100.0
            : isLargeDesktop
                ? 80.0
                : isDesktop
                    ? 60.0
                    : isTablet
                        ? 40.0
                        : 24.0;

    // Tamaño de fuente responsivo - Más legible y proporcional
    double baseFontSize = isTV
        ? 52.0
        : isUltraWide
            ? 42.0
            : isLargeDesktop
                ? 32.0
                : isDesktop
                    ? 24.0
                    : isTablet
                        ? 18.0
                        : 16.0;

    // Ancho máximo responsivo
    double maxWidth = isTV
        ? double.infinity // Sin límite para TV
        : isUltraWide
            ? 2800
            : isLargeDesktop
                ? 2200
                : isDesktop
                    ? 1600
                    : isTablet
                        ? 1200
                        : double.infinity; // Sin límite para móvil

    // Espaciado entre columnas responsivo - Más amplio para mejor separación visual
    double columnSpacing = isTV
        ? 60.0
        : isUltraWide
            ? 48.0
            : isLargeDesktop
                ? 36.0
                : isDesktop
                    ? 32.0
                    : isTablet
                        ? 24.0
                        : 20.0;

    // Flex ratios responsivos
    int leftColumnFlex = isTV
        ? 4
        : isUltraWide
            ? 3
            : isLargeDesktop
                ? 3
                : isDesktop
                    ? 3
                    : isTablet
                        ? 2
                        : 1;

    int rightColumnFlex = isTV
        ? 1
        : isUltraWide
            ? 1
            : isLargeDesktop
                ? 1
                : isDesktop
                    ? 1
                    : isTablet
                        ? 1
                        : 1;

    final provider = Provider.of<AsistenciaProvider>(context);
    // Calcular métricas basadas en datos reales disponibles
    final asistenciasDetalle = provider.asistenciasDetalle;
    
    // Debug: Mostrar información de las asistencias
    debugPrint('🔍 Dashboard - Jornada actual: ${provider.jornadaActual}');
    debugPrint('🔍 Dashboard - Asistencias detalle: ${asistenciasDetalle.length}');
    debugPrint('🔍 Dashboard - Todas las fichas: ${provider.fichas.length}');
    
    // Debug detallado de asistencias
    for (var asistencia in asistenciasDetalle.take(5)) {
      debugPrint('   - Asistencia: Ficha ${asistencia.ficha}, Aprendiz ${asistencia.aprendiz}, Jornada ${asistencia.jornada}');
    }

    // Calcular fichas únicas desde las asistencias
    final fichasUnicas = asistenciasDetalle.map((a) => a.ficha).toSet();
    final totalFichas = fichasUnicas.length;
    
    // Calcular aprendices únicos por ficha desde asistenciasDetalle
    final Map<String, Set<String>> aprendicesPorFicha = {};
    for (var asistencia in asistenciasDetalle) {
      aprendicesPorFicha.putIfAbsent(asistencia.ficha, () => <String>{}).add(asistencia.numeroDocumento);
    }
    
    // Calcular totales
    int totalAprendicesEsperados = 0;
    int totalPresentes = 0;
    
    // Para cada ficha única, calcular aprendices esperados y presentes
    for (var fichaStr in fichasUnicas) {
      final aprendicesEnFicha = aprendicesPorFicha[fichaStr]?.length ?? 0;
      
      // Asumir que cada ficha tiene un número esperado de aprendices
      // En el futuro esto debería venir del modelo FichaModel
      final aprendicesEsperadosPorFicha = 20; // Valor por defecto
      
      totalAprendicesEsperados += aprendicesEsperadosPorFicha;
      totalPresentes += aprendicesEnFicha;
    }
    
    // Calcular ausentes como diferencia
    final totalAusentes = totalAprendicesEsperados - totalPresentes;
    
    // Calcular porcentaje de asistencia
    final porcentajeAsistencia = totalAprendicesEsperados > 0
        ? (totalPresentes / totalAprendicesEsperados * 100).round()
        : 0;

    debugPrint(
      '🔍 Dashboard - Total fichas: $totalFichas, Esperados: $totalAprendicesEsperados, Presentes: $totalPresentes, Ausentes: $totalAusentes, %: $porcentajeAsistencia%',
    );

    final fechaActual = _formatDate(DateTime.now());
    final horaActual = DateFormat('h:mm a').format(DateTime.now());
    final jornadaActual = provider.jornadaActual.isNotEmpty
        ? provider.jornadaActual
        : 'Fuera de jornada';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Consumer<AsistenciaProvider>(
        builder: (context, providerConsumer, _) {
          // Mostrar estado de carga o error
          if (providerConsumer.isLoading &&
              providerConsumer.estadisticas.isEmpty) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Cargando Dashboard',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Obteniendo datos de asistencia...',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (providerConsumer.hasError) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
              ),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Error al cargar datos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        providerConsumer.errorMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => providerConsumer.cargarDatos(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Reintentar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
                  stops: [0.0, 1.0],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(basePadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: isMobile
                        ? _buildMobileLayout(
                            basePadding: basePadding,
                            baseFontSize: baseFontSize,
                            maxWidth: maxWidth,
                            fechaActual: fechaActual,
                            horaActual: horaActual,
                            jornadaActual: jornadaActual,
                            providerConsumer: providerConsumer,
                            totalFichas: totalFichas,
                            totalPresentes: totalPresentes,
                            totalAusentes: totalAusentes,
                            porcentajeAsistencia: porcentajeAsistencia,
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Columna izquierda: Todo el contenido principal
                              Expanded(
                                flex: leftColumnFlex,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header section
                                    DashboardHeader(
                                      fecha: fechaActual,
                                      hora: horaActual,
                                      jornada: jornadaActual,
                                      isUpdating: providerConsumer.isUpdating,
                                    ),
                                    SizedBox(height: basePadding),

                                    // KPI Principal - Porcentaje de Asistencia (Hero)
                                    Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFF10B981),
                                            const Color(0xFF059669),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF10B981)
                                                .withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          // Icono principal
                                          Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            child: Icon(
                                              Icons.trending_up_rounded,
                                              color: Colors.white,
                                              size: 24.w,
                                            ),
                                          ),
                                          SizedBox(width: 16.w),
                                          // Información principal
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Asistencia del Día',
                                                  style: TextStyle(
                                                    fontSize:
                                                        baseFontSize * 1.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                  ),
                                                ),
                                                SizedBox(height: 6.h),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '$porcentajeAsistencia',
                                                      style: TextStyle(
                                                        fontSize:
                                                            baseFontSize * 3.0,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                          fontSize:
                                                              baseFontSize *
                                                                  1.5,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: basePadding),

                                    // Métricas Complementarias (sin redundancia)
                                    Row(
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
                                            value: jornadaActual,
                                            icon: Icons.schedule_rounded,
                                            color: const Color(0xFF8B5CF6),
                                            baseFontSize: baseFontSize,
                                            isTextValue: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: basePadding),

                                    // Estadísticas Generales
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF3B82F6),
                                                Color(0xFF1D4ED8),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: Icon(
                                            Icons.analytics_rounded,
                                            color: Colors.white,
                                            size: 28.w,
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        Text(
                                          'Estadísticas Generales',
                                          style: TextStyle(
                                            fontSize: baseFontSize * 2.0,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    const UltraFastAsistenciasWidget(),
                                  ],
                                ),
                              ),

                              SizedBox(width: columnSpacing.w),

                              // Columna derecha: Solo Fichas en Formación
                              Expanded(
                                flex: rightColumnFlex,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header de Fichas en Formación
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF10B981),
                                                Color(0xFF059669),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: Icon(
                                            Icons.school_rounded,
                                            color: Colors.white,
                                            size: 28.w,
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: Text(
                                            'Fichas en Formación',
                                            style: TextStyle(
                                              fontSize: baseFontSize * 2.0,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    const FichasEnFormacionWidget(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Layout responsivo para móviles
  Widget _buildMobileLayout({
    required double basePadding,
    required double baseFontSize,
    required double maxWidth,
    required String fechaActual,
    required String horaActual,
    required String jornadaActual,
    required AsistenciaProvider providerConsumer,
    required int totalFichas,
    required int totalPresentes,
    required int totalAusentes,
    required int porcentajeAsistencia,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        DashboardHeader(
          fecha: fechaActual,
          hora: horaActual,
          jornada: jornadaActual,
          isUpdating: providerConsumer.isUpdating,
        ),
        SizedBox(height: basePadding),

        // KPI Principal - Porcentaje de Asistencia (Hero)
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF10B981),
                const Color(0xFF059669),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Icono principal
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 32.w,
                ),
              ),
              SizedBox(height: 16.h),
              // Información principal
              Text(
                'Asistencia del Día',
                style: TextStyle(
                  fontSize: baseFontSize * 1.2,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$porcentajeAsistencia',
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
                      porcentajeAsistencia >= 90
                          ? Icons.sentiment_very_satisfied_rounded
                          : porcentajeAsistencia >= 70
                              ? Icons.sentiment_satisfied_rounded
                              : Icons.sentiment_dissatisfied_rounded,
                      color: Colors.white,
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      porcentajeAsistencia >= 90
                          ? 'Excelente'
                          : porcentajeAsistencia >= 70
                              ? 'Bueno'
                              : 'Bajo',
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
        SizedBox(height: basePadding),

        // Métricas Complementarias (2x2 en móvil)
        Column(
          children: [
            Row(
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
                SizedBox(width: 8.w),
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
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
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
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildMetricCard(
                    context: context,
                    title: 'Jornada',
                    value: jornadaActual,
                    icon: Icons.schedule_rounded,
                    color: const Color(0xFF8B5CF6),
                    baseFontSize: baseFontSize,
                    isTextValue: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: basePadding),

        // Estadísticas Generales
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF1D4ED8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              'Estadísticas Generales',
              style: TextStyle(
                fontSize: baseFontSize * 1.8,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        const UltraFastAsistenciasWidget(),

        SizedBox(height: basePadding),

        // Fichas en Formación
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF10B981),
                    Color(0xFF059669),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              'Fichas en Formación',
              style: TextStyle(
                fontSize: baseFontSize * 1.8,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        const FichasEnFormacionWidget(),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final days = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    final weekday = days[date.weekday % 7];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    return '$weekday, $day de $month de $year';
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
          // Valor principal
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
