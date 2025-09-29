import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../providers/asistencia_provider.dart';
import '../models/websocket_event.dart';
import '../utils/constants.dart';

/// Widget que muestra las últimas asistencias registradas en tiempo real
class AsistenciasTiempoRealWidget extends StatelessWidget {
  const AsistenciasTiempoRealWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
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
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
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
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Asistencias en Tiempo Real',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              // Indicador de WebSocket conectado
              Consumer<AsistenciaProvider>(
                builder: (context, provider, _) {
                  final isConnected = provider.isWebSocketConnected;
                  return Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: isConnected
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        isConnected ? 'En vivo' : 'Desconectado',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isConnected
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Lista de asistencias
          Consumer<AsistenciaProvider>(
            builder: (context, provider, _) {
              final asistencias = provider.ultimasAsistenciasWebSocket;

              if (asistencias.isEmpty) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 48.w,
                          color: const Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Esperando nuevas asistencias...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: asistencias.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final asistencia = asistencias[index];
                  return _AsistenciaItem(event: asistencia);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Widget individual para cada asistencia
class _AsistenciaItem extends StatelessWidget {
  final WebSocketEvent event;

  const _AsistenciaItem({required this.event});

  @override
  Widget build(BuildContext context) {
    final isEntrada = event.estadoAsistencia?.toLowerCase() == 'entrada';
    final color =
        isEntrada ? DesignConstants.successGreen : DesignConstants.errorRed;
    final icon = isEntrada ? Icons.login_rounded : Icons.logout_rounded;
    final horaFormato = DateFormat('HH:mm:ss').format(event.timestamp);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icono de estado
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16.w,
            ),
          ),
          SizedBox(width: 12.w),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.aprendizNombre ?? 'Aprendiz desconocido',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
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
                      color: const Color(0xFF64748B),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Ficha ${event.fichaId ?? "N/A"}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    if (event.jornada != null) ...[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.wb_sunny_rounded,
                        size: 12.w,
                        color: const Color(0xFF64748B),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        event.jornada!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Estado y hora
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  event.estadoAsistencia?.toUpperCase() ?? 'N/A',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                horaFormato,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

