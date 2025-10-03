import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/robust_asistencia_provider.dart';
import '../utils/constants.dart';

/// Widget que muestra el estado de conexión robusto con indicadores visuales
class RobustConnectionStatusWidget extends StatelessWidget {
  const RobustConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RobustAsistenciaProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _getStatusColor(provider),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: _getStatusColor(provider).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIcon(provider),
              SizedBox(width: 8.w),
              _buildStatusText(provider),
              if (provider.isPollingActive) ...[
                SizedBox(width: 8.w),
                _buildPollingIndicator(),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Construye el ícono de estado
  Widget _buildStatusIcon(RobustAsistenciaProvider provider) {
    IconData icon;
    Color color;

    if (provider.isWebSocketConnected) {
      icon = Icons.wifi;
      color = Colors.white;
    } else if (provider.isPollingActive) {
      icon = Icons.sync;
      color = Colors.white;
    } else if (provider.webSocketState == 'reconectando') {
      icon = Icons.refresh;
      color = Colors.white;
    } else {
      icon = Icons.wifi_off;
      color = Colors.white;
    }

    return Icon(
      icon,
      size: 16.w,
      color: color,
    );
  }

  /// Construye el texto de estado
  Widget _buildStatusText(RobustAsistenciaProvider provider) {
    String text;
    
    if (provider.isWebSocketConnected) {
      text = 'Conectado';
    } else if (provider.isPollingActive) {
      text = 'Polling';
    } else if (provider.webSocketState == 'reconectando') {
      text = 'Reconectando...';
    } else {
      text = 'Desconectado';
    }

    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Construye el indicador de polling
  Widget _buildPollingIndicator() {
    return SizedBox(
      width: 12.w,
      height: 12.h,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  /// Obtiene el color de estado
  Color _getStatusColor(RobustAsistenciaProvider provider) {
    if (provider.isWebSocketConnected) {
      return DesignConstants.successGreen;
    } else if (provider.isPollingActive) {
      return DesignConstants.warningOrange;
    } else if (provider.webSocketState == 'reconectando') {
      return DesignConstants.cyan;
    } else {
      return DesignConstants.errorRed;
    }
  }
}

/// Widget compacto para mostrar estado de conexión en header
class CompactConnectionStatusWidget extends StatelessWidget {
  const CompactConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RobustAsistenciaProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _getStatusColor(provider),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(provider),
                size: 12.w,
                color: Colors.white,
              ),
              SizedBox(width: 4.w),
              Text(
                _getStatusText(provider),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Obtiene el ícono de estado
  IconData _getStatusIcon(RobustAsistenciaProvider provider) {
    if (provider.isWebSocketConnected) {
      return Icons.wifi;
    } else if (provider.isPollingActive) {
      return Icons.sync;
    } else {
      return Icons.wifi_off;
    }
  }

  /// Obtiene el texto de estado
  String _getStatusText(RobustAsistenciaProvider provider) {
    if (provider.isWebSocketConnected) {
      return 'WS';
    } else if (provider.isPollingActive) {
      return 'POLL';
    } else {
      return 'OFF';
    }
  }

  /// Obtiene el color de estado
  Color _getStatusColor(RobustAsistenciaProvider provider) {
    if (provider.isWebSocketConnected) {
      return DesignConstants.successGreen;
    } else if (provider.isPollingActive) {
      return DesignConstants.warningOrange;
    } else {
      return DesignConstants.errorRed;
    }
  }
}

/// Widget de estado de datos con información detallada
class DataStatusWidget extends StatelessWidget {
  const DataStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RobustAsistenciaProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: DesignConstants.borderLight),
            boxShadow: DesignConstants.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado de Datos',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: DesignConstants.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              _buildStatusRow('Conexión WebSocket', provider.isWebSocketConnected),
              _buildStatusRow('Polling Activo', provider.isPollingActive),
              _buildStatusRow('Actualizando', provider.isUpdating),
              _buildStatusRow('Con Error', provider.hasError),
              SizedBox(height: 8.h),
              if (provider.lastDataUpdate != null)
                Text(
                  'Última actualización: ${_formatDateTime(provider.lastDataUpdate!)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: DesignConstants.textSecondary,
                  ),
                ),
              SizedBox(height: 8.h),
              Text(
                'Asistencias: ${provider.asistenciasDetalle.length}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: DesignConstants.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye una fila de estado
  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            size: 16.w,
            color: status ? DesignConstants.successGreen : DesignConstants.errorRed,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: DesignConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Formatea fecha y hora
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
