import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/asistencia_detalle_model.dart';
import '../services/reactive_asistencias_service.dart';
import '../providers/reactive_asistencia_provider.dart';
import '../widgets/websocket_connection_status.dart';
import '../utils/constants.dart';

/// Widget completamente reactivo que muestra asistencias con actualizaciones granulares
/// Solo reconstruye las partes que han cambiado
class ReactiveAsistenciasWidget extends StatefulWidget {
  const ReactiveAsistenciasWidget({super.key});

  @override
  State<ReactiveAsistenciasWidget> createState() =>
      _ReactiveAsistenciasWidgetState();
}

class _ReactiveAsistenciasWidgetState extends State<ReactiveAsistenciasWidget> {
  ReactiveAsistenciasService? _reactiveService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWithProvider();
    });
  }

  /// Inicializa el servicio con datos del provider
  void _initializeWithProvider() {
    final provider = context.read<ReactiveAsistenciaProvider>();
    _reactiveService = provider.reactiveService;
  }

  @override
  void dispose() {
    // El servicio se limpia en el provider
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReactiveAsistenciaProvider>(
      builder: (context, provider, _) {
        // Si el servicio aún no está inicializado, usar el provider
        final reactiveService = _reactiveService ?? provider.reactiveService;

        return StreamBuilder<List<AsistenciaDetalle>>(
          stream: reactiveService.asistenciasStream,
          builder: (context, snapshot) {
            // Estado de carga inicial
            if (provider.isLoading && !snapshot.hasData) {
              return _buildLoadingState();
            }

            // Estado de error
            if (provider.hasError) {
              return _buildErrorState(provider.errorMessage);
            }

            // Obtener datos
            final asistencias = snapshot.data ?? provider.asistenciasIniciales;

            // Estado vacío
            if (asistencias.isEmpty) {
              return _buildEmptyState();
            }

            // Estado con datos - mostrar asistencias reactivas
            return _buildReactiveContent(asistencias, reactiveService);
          },
        );
      },
    );
  }

  /// Widget de estado de carga
  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Conectando en tiempo real...',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: DesignConstants.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Esperando datos del WebSocket',
              style: TextStyle(
                fontSize: 12.sp,
                color: DesignConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de estado de error
  Widget _buildErrorState(String error) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 32.w,
                color: const Color(0xFFEF4444),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Error de conexión',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: DesignConstants.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'No se pudieron cargar las asistencias',
              style: TextStyle(
                fontSize: 14.sp,
                color: DesignConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFFEF4444),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de estado vacío
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 32.w,
                color: DesignConstants.primaryBlue,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No hay asistencias registradas',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: DesignConstants.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Las asistencias aparecerán aquí automáticamente cuando se registren',
              style: TextStyle(
                fontSize: 14.sp,
                color: DesignConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            const WebSocketConnectionStatus(),
          ],
        ),
      ),
    );
  }

  /// Widget principal con contenido reactivo
  Widget _buildReactiveContent(List<AsistenciaDetalle> asistencias,
      ReactiveAsistenciasService reactiveService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen general reactivo
        _ReactiveResumenGeneral(asistencias: asistencias),
        SizedBox(height: 16.h),

        // Indicador de estado WebSocket
        const WebSocketConnectionStatus(),
        SizedBox(height: 16.h),

        // Asistencias por jornada reactivas
        ...reactiveService.jornadasDisponibles.map((jornada) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _ReactiveJornadaSection(
              jornada: jornada,
              reactiveService: reactiveService,
            ),
          );
        }),
      ],
    );
  }
}

/// Widget reactivo para el resumen general
class _ReactiveResumenGeneral extends StatelessWidget {
  final List<AsistenciaDetalle> asistencias;

  const _ReactiveResumenGeneral({required this.asistencias});

  @override
  Widget build(BuildContext context) {
    final enCurso = asistencias.where((a) => a.isEnCurso).length;
    final completas = asistencias.where((a) => a.isCompleta).length;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.group_rounded,
              label: 'Total Asistencias',
              value: asistencias.length.toString(),
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.pending_actions_rounded,
              label: 'En Curso',
              value: enCurso.toString(),
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_rounded,
              label: 'Completas',
              value: completas.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24.w,
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Widget reactivo para una sección de jornada
class _ReactiveJornadaSection extends StatelessWidget {
  final String jornada;
  final ReactiveAsistenciasService reactiveService;

  const _ReactiveJornadaSection({
    required this.jornada,
    required this.reactiveService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AsistenciaDetalle>>(
      stream: reactiveService.getJornadaStream(jornada),
      builder: (context, snapshot) {
        final asistencias =
            snapshot.data ?? reactiveService.getAsistenciasJornada(jornada);

        // Estado vacío para esta jornada
        if (asistencias.isEmpty) {
          return _buildEmptyJornadaState(jornada);
        }

        return _buildJornadaContent(jornada, asistencias);
      },
    );
  }

  /// Widget para jornada vacía
  Widget _buildEmptyJornadaState(String jornada) {
    final jornadaInfo = _getJornadaInfo(jornada);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la jornada
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: jornadaInfo.color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: jornadaInfo.color,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    jornadaInfo.icon,
                    color: Colors.white,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  jornada,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: DesignConstants.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: jornadaInfo.color,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '0 asistencias',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Estado vacío
          Padding(
            padding: EdgeInsets.all(32.w),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.person_add_disabled_rounded,
                    size: 32.w,
                    color: DesignConstants.textSecondary,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No hay asistencias en $jornada',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: DesignConstants.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Las asistencias aparecerán aquí automáticamente',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: DesignConstants.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget con contenido de la jornada
  Widget _buildJornadaContent(
      String jornada, List<AsistenciaDetalle> asistencias) {
    final jornadaInfo = _getJornadaInfo(jornada);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          // Header de la jornada
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: jornadaInfo.color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: jornadaInfo.color,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    jornadaInfo.icon,
                    color: Colors.white,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  jornada,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: DesignConstants.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: jornadaInfo.color,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${asistencias.length} asistencias',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de asistencias reactivas
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: asistencias.length,
            separatorBuilder: (context, index) => Divider(
              height: 16.h,
              color: const Color(0xFFE2E8F0),
            ),
            itemBuilder: (context, index) {
              final asistencia = asistencias[index];
              return _ReactiveAsistenciaItem(
                asistencia: asistencia,
                reactiveService: reactiveService,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Obtiene la información visual de la jornada
  _JornadaInfo _getJornadaInfo(String jornada) {
    switch (jornada.toUpperCase()) {
      case 'MAÑANA':
        return _JornadaInfo(
          color: const Color(0xFFF59E0B),
          icon: Icons.wb_sunny_rounded,
        );
      case 'TARDE':
        return _JornadaInfo(
          color: const Color(0xFF8B5CF6),
          icon: Icons.wb_twilight_rounded,
        );
      case 'NOCHE':
        return _JornadaInfo(
          color: const Color(0xFF6366F1),
          icon: Icons.nightlight_round_rounded,
        );
      default:
        return _JornadaInfo(
          color: DesignConstants.primaryBlue,
          icon: Icons.access_time_rounded,
        );
    }
  }
}

/// Widget reactivo para un item de asistencia individual
class _ReactiveAsistenciaItem extends StatelessWidget {
  final AsistenciaDetalle asistencia;
  final ReactiveAsistenciasService reactiveService;

  const _ReactiveAsistenciaItem({
    required this.asistencia,
    required this.reactiveService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AsistenciaDetalle>(
      stream: reactiveService.asistenciaActualizadaStream
          .where((a) => a.id == asistencia.id),
      builder: (context, snapshot) {
        final asistenciaActual = snapshot.data ?? asistencia;
        return _buildAsistenciaContent(asistenciaActual);
      },
    );
  }

  Widget _buildAsistenciaContent(AsistenciaDetalle asistencia) {
    final isEnCurso = asistencia.isEnCurso;
    final estadoColor = isEnCurso
        ? DesignConstants.warningOrange
        : DesignConstants.successGreen;
    final estadoTexto = isEnCurso ? 'EN CURSO' : 'COMPLETA';
    final estadoIcon =
        isEnCurso ? Icons.pending_rounded : Icons.check_circle_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Row(
        children: [
          // Icono de estado con animación
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: estadoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              estadoIcon,
              color: estadoColor,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),

          // Información del aprendiz
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asistencia.aprendiz,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: DesignConstants.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.badge_rounded,
                      size: 12.w,
                      color: DesignConstants.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Ficha ${asistencia.ficha}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: DesignConstants.textSecondary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(
                      Icons.credit_card_rounded,
                      size: 12.w,
                      color: DesignConstants.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      asistencia.numeroDocumento,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: DesignConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Horarios y estado con animación
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: estadoColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    estadoTexto,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 12.w,
                      color: DesignConstants.successGreen,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      asistencia.horaIngreso,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: DesignConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (asistencia.horaSalida != null) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 12.w,
                        color: DesignConstants.errorRed,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        asistencia.horaSalida!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: DesignConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Clase para información de jornada
class _JornadaInfo {
  final Color color;
  final IconData icon;

  const _JornadaInfo({
    required this.color,
    required this.icon,
  });
}
