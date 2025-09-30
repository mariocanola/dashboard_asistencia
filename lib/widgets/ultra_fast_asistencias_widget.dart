import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/asistencia_detalle_model.dart';
import '../providers/asistencia_provider.dart';
import '../services/ultra_fast_asistencias_service.dart';
import '../utils/constants.dart';

/// Widget ultra-optimizado para manejar miles de asistencias en tiempo real
/// Máximo 5 segundos de actualización, optimizado para alta carga
class UltraFastAsistenciasWidget extends StatefulWidget {
  const UltraFastAsistenciasWidget({super.key});

  @override
  State<UltraFastAsistenciasWidget> createState() => _UltraFastAsistenciasWidgetState();
}

class _UltraFastAsistenciasWidgetState extends State<UltraFastAsistenciasWidget> {
  final UltraFastAsistenciasService _ultraFastService = UltraFastAsistenciasService();
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _initializeUltraFastService();
    _startStatusUpdates();
  }

  /// Inicializa el servicio ultra-rápido
  void _initializeUltraFastService() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AsistenciaProvider>();
      _ultraFastService.initialize(provider);
    });
  }

  /// Inicia actualizaciones de estado
  void _startStatusUpdates() {
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {}); // Forzar rebuild para mostrar estado actualizado
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _ultraFastService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AsistenciaProvider>(
      builder: (context, provider, _) {
        final asistencias = provider.asistenciasDetalle;

        // Estado de carga inicial
        if (provider.isLoading && asistencias.isEmpty) {
          return _buildLoadingState();
        }

        // Estado de error
        if (provider.hasError) {
          return _buildErrorState(provider.errorMessage);
        }

        // Estado vacío
        if (asistencias.isEmpty) {
          return _buildEmptyState();
        }

        // Estado con datos - ultra optimizado
        return _buildUltraFastContent(asistencias, provider);
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
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
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
              'Iniciando modo ultra-rápido...',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: DesignConstants.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Máximo 5 segundos de actualización',
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
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                final provider = context.read<AsistenciaProvider>();
                _ultraFastService.forceRefresh(provider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignConstants.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: Text('Reintentar'),
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
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 32.w,
                color: const Color(0xFF10B981),
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
              'Las asistencias aparecerán aquí en máximo 5 segundos',
              style: TextStyle(
                fontSize: 14.sp,
                color: DesignConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            _buildUltraFastStatusIndicator(),
          ],
        ),
      ),
    );
  }

  /// Widget principal ultra-optimizado
  Widget _buildUltraFastContent(List<AsistenciaDetalle> asistencias, AsistenciaProvider provider) {
    // Agrupar asistencias por jornada - optimizado
    final Map<String, List<AsistenciaDetalle>> porJornada = {};
    for (var asistencia in asistencias) {
      porJornada.putIfAbsent(asistencia.jornada, () => []).add(asistencia);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen general ultra-rápido
        _buildUltraFastResumen(asistencias),
        SizedBox(height: 16.h),

        // Indicador de estado ultra-rápido
        _buildUltraFastStatusIndicator(),
        SizedBox(height: 16.h),

        // Botones de prueba ultra-rápida (solo en debug)
        if (kDebugMode) ...[
          _buildUltraFastTestButtons(provider),
          SizedBox(height: 16.h),
        ],

        // Asistencias por jornada - optimizadas
        ...porJornada.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildUltraFastJornadaSection(
              jornada: entry.key,
              asistencias: entry.value,
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Widget de resumen ultra-rápido (optimizado - sin redundancia)
  Widget _buildUltraFastResumen(List<AsistenciaDetalle> asistencias) {
    final enCurso = asistencias.where((a) => a.isEnCurso).length;
    final completas = asistencias.where((a) => a.isCompleta).length;
    final responseTime = _ultraFastService.getResponseTime();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
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
          Container(
            width: 1,
            height: 40.h,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.speed_rounded,
              label: 'Tiempo Respuesta',
              value: responseTime,
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
          size: 20.w,
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Widget de indicador de estado ultra-rápido
  Widget _buildUltraFastStatusIndicator() {
    final status = _ultraFastService.getStatus();
    final isWebSocketConnected = status['webSocketConnected'] as bool;
    final isFastPollingActive = status['fastPollingActive'] as bool;
    final lastUpdate = status['lastUpdate'] as String?;
    final pendingChanges = status['pendingChanges'] as int;
    final pollingInterval = status['pollingInterval'] as int;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isWebSocketConnected) {
      statusColor = const Color(0xFF10B981);
      statusText = 'WebSocket Ultra-Rápido';
      statusIcon = Icons.bolt_rounded;
    } else if (isFastPollingActive) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'Polling Ultra-Rápido (${pollingInterval}s)';
      statusIcon = Icons.speed_rounded;
    } else {
      statusColor = const Color(0xFF6B7280);
      statusText = 'Desconectado';
      statusIcon = Icons.wifi_off_rounded;
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                if (lastUpdate != null) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        'Última actualización: ${_formatLastUpdate(lastUpdate)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: DesignConstants.textSecondary,
                        ),
                      ),
                      if (pendingChanges > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '$pendingChanges cambios',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  /// Widget de botones de prueba ultra-rápida
  Widget _buildUltraFastTestButtons(AsistenciaProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                color: const Color(0xFF059669),
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Modo Ultra-Rápido - Pruebas',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _ultraFastService.forceRefresh(provider);
                },
                icon: Icon(Icons.bolt_rounded, size: 16.w),
                label: Text('Actualizar Ahora', style: TextStyle(fontSize: 12.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  provider.cargarDatos();
                },
                icon: Icon(Icons.download_rounded, size: 16.w),
                label: Text('Cargar Datos', style: TextStyle(fontSize: 12.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _simulateHighLoad(provider);
                },
                icon: Icon(Icons.burst_mode_rounded, size: 16.w),
                label: Text('Simular Carga Alta', style: TextStyle(fontSize: 12.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Simula carga alta para pruebas
  void _simulateHighLoad(AsistenciaProvider provider) {
    debugPrint('🚀 Simulando carga alta - 10 actualizaciones rápidas');
    
    for (int i = 0; i < 10; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        _ultraFastService.forceRefresh(provider);
      });
    }
  }

  /// Widget de sección por jornada ultra-optimizada
  Widget _buildUltraFastJornadaSection({
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
                  child: Icon(
                    icon,
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

          // Lista de asistencias optimizada
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: asistencias.length,
            separatorBuilder: (context, index) => Divider(
              height: 12.h,
              color: const Color(0xFFE2E8F0),
            ),
            itemBuilder: (context, index) {
              final asistencia = asistencias[index];
              return _buildUltraFastAsistenciaItem(asistencia);
            },
          ),
        ],
      ),
    );
  }

  /// Widget de item de asistencia ultra-optimizado
  Widget _buildUltraFastAsistenciaItem(AsistenciaDetalle asistencia) {
    final isEnCurso = asistencia.isEnCurso;
    final estadoColor = isEnCurso
        ? DesignConstants.warningOrange
        : DesignConstants.successGreen;
    final estadoTexto = isEnCurso ? 'EN CURSO' : 'COMPLETA';
    final estadoIcon =
        isEnCurso ? Icons.pending_rounded : Icons.check_circle_rounded;

    return Container(
      child: Row(
        children: [
          // Icono de estado
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: estadoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              estadoIcon,
              color: estadoColor,
              size: 16.w,
            ),
          ),
          SizedBox(width: 10.w),

          // Información del aprendiz - compacta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asistencia.aprendiz,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: DesignConstants.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      'Ficha ${asistencia.ficha}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: DesignConstants.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      asistencia.numeroDocumento,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: DesignConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Horarios y estado - compacto
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: estadoColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  estadoTexto,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                asistencia.horaIngreso,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: DesignConstants.textSecondary,
                ),
              ),
              if (asistencia.horaSalida != null)
                Text(
                  asistencia.horaSalida!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: DesignConstants.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formatea la última actualización
  String _formatLastUpdate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inSeconds < 60) {
        return 'hace ${difference.inSeconds}s';
      } else if (difference.inMinutes < 60) {
        return 'hace ${difference.inMinutes}m';
      } else {
        return 'hace ${difference.inHours}h';
      }
    } catch (e) {
      return 'desconocido';
    }
  }
}
