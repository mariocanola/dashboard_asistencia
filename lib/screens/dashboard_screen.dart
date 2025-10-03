import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../providers/asistencia_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/ultra_fast_asistencias_widget.dart';
import '../widgets/fichas_en_formacion_widget.dart';
import '../widgets/metrics_cards_widget.dart';
import '../widgets/main_kpi_card_widget.dart';

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

    // Debug: Mostrar información básica
    debugPrint('🔍 Dashboard - Jornada actual: ${provider.jornadaActual}');
    debugPrint(
        '🔍 Dashboard - Asistencias detalle: ${provider.asistenciasDetalle.length}');
    debugPrint('🔍 Dashboard - Todas las fichas: ${provider.fichas.length}');

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
                                    MainKPICardWidget(
                                        baseFontSize: baseFontSize),
                                    SizedBox(height: basePadding),

                                    // Métricas Complementarias (optimizadas para WebSocket)
                                    MetricsCardsWidget(
                                      baseFontSize: baseFontSize,
                                      jornadaActual: jornadaActual,
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
                    '0',
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
                      Icons.sentiment_very_satisfied_rounded,
                      color: Colors.white,
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Excelente',
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

        // Métricas Complementarias (optimizadas para WebSocket)
        MetricsCardsWidget(
          baseFontSize: baseFontSize,
          jornadaActual: jornadaActual,
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
}
