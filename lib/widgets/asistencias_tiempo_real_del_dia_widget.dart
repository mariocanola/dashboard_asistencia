import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/asistencia_detalle_model.dart';
import '../services/asistencias_stream_service.dart';
import '../providers/asistencia_provider.dart';
import '../widgets/websocket_connection_status.dart';
import '../utils/constants.dart';

/// Widget que muestra las asistencias del día en tiempo real usando StreamBuilder
/// Reemplaza el sistema de polling por eventos WebSocket en tiempo real
class AsistenciasTiempoRealDelDiaWidget extends StatefulWidget {
  const AsistenciasTiempoRealDelDiaWidget({super.key});

  @override
  State<AsistenciasTiempoRealDelDiaWidget> createState() =>
      _AsistenciasTiempoRealDelDiaWidgetState();
}

class _AsistenciasTiempoRealDelDiaWidgetState
    extends State<AsistenciasTiempoRealDelDiaWidget> {
  late final AsistenciasStreamService _streamService;

  @override
  void initState() {
    super.initState();
    _streamService = AsistenciasStreamService();

    // Inicializar el servicio después de que el widget se monte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStreamService();
    });
  }

  Future<void> _initializeStreamService() async {
    final provider = context.read<AsistenciaProvider>();
    await _streamService.initialize(provider);
  }

  @override
  void dispose() {
    _streamService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AsistenciaDetalle>>(
      stream: _streamService.asistenciasStream,
      builder: (context, snapshot) {
        // Estado de carga inicial
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildLoadingState();
        }

        // Estado de error
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        // Obtener datos
        final asistencias = snapshot.data ?? [];

        // Estado vacío
        if (asistencias.isEmpty) {
          return _buildEmptyState();
        }

        // Estado con datos - mostrar asistencias
        return _buildAsistenciasContent(asistencias);
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
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFFEF4444)),
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
            // Indicador de conexión WebSocket
            const WebSocketConnectionStatus(),
          ],
        ),
      ),
    );
  }

  /// Widget principal con asistencias
  Widget _buildAsistenciasContent(List<AsistenciaDetalle> asistencias) {
    // Agrupar asistencias por jornada
    final Map<String, List<AsistenciaDetalle>> porJornada = {};
    for (var asistencia in asistencias) {
      if (!porJornada.containsKey(asistencia.jornada)) {
        porJornada[asistencia.jornada] = [];
      }
      porJornada[asistencia.jornada]!.add(asistencia);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen general
        _buildResumenGeneral(asistencias),
        SizedBox(height: 16.h),

        // Indicador de estado WebSocket
        const WebSocketConnectionStatus(),
        SizedBox(height: 16.h),

        // Asistencias por jornada
        ...porJornada.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildJornadaSection(
              jornada: entry.key,
              asistencias: entry.value,
            ),
          );
        }),
      ],
    );
  }

  /// Widget de resumen general
  Widget _buildResumenGeneral(List<AsistenciaDetalle> asistencias) {
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
        Icon(icon, color: Colors.white, size: 24.w),
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

  /// Widget de sección por jornada
  Widget _buildJornadaSection({
    required String jornada,
    required List<AsistenciaDetalle> asistencias,
  }) {
    // Color según jornada
    Color color;
    IconData icon;
    switch (jornada.toUpperCase()) {
      case 'MAÑANA':
        color = const Color(0xFFF59E0B);
        icon = Icons.wb_sunny_rounded;
        break;
      case 'TARDE':
        color = const Color(0xFF8B5CF6);
        icon = Icons.wb_twilight_rounded;
        break;
      case 'NOCHE':
        color = const Color(0xFF6366F1);
        icon = Icons.nightlight_round_rounded;
        break;
      default:
        color = DesignConstants.primaryBlue;
        icon = Icons.access_time_rounded;
    }

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
              color: color.withOpacity(0.1),
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
                    color: color,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20.w),
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
                    color: color,
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

          // Lista de asistencias
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: asistencias.length,
            separatorBuilder: (context, index) =>
                Divider(height: 16.h, color: const Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final asistencia = asistencias[index];
              return _buildAsistenciaItem(asistencia);
            },
          ),
        ],
      ),
    );
  }

  /// Widget de item de asistencia
  Widget _buildAsistenciaItem(AsistenciaDetalle asistencia) {
    final isEnCurso = asistencia.isEnCurso;
    final estadoColor = isEnCurso
        ? DesignConstants.warningOrange
        : DesignConstants.successGreen;
    final estadoTexto = isEnCurso ? 'EN CURSO' : 'COMPLETA';
    final estadoIcon =
        isEnCurso ? Icons.pending_rounded : Icons.check_circle_rounded;

    return Row(
      children: [
        // Icono de estado
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: estadoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(estadoIcon, color: estadoColor, size: 20.w),
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

        // Horarios y estado
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
      ],
    );
  }
}
