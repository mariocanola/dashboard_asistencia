import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/robust_asistencia_provider.dart';
import '../utils/constants.dart';

/// Widget que muestra el estado de los datos con manejo resiliente de errores
class ResilientDataStatusWidget extends StatelessWidget {
  const ResilientDataStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RobustAsistenciaProvider>(
      builder: (context, provider, _) {
        // Si hay error pero tenemos datos en cache, mostrar datos con advertencia
        if (provider.hasError && provider.asistenciasDetalle.isNotEmpty) {
          return _buildWarningState(provider);
        }
        
        // Si hay error y no hay datos, mostrar estado de error
        if (provider.hasError && provider.asistenciasDetalle.isEmpty) {
          return _buildErrorState(provider);
        }
        
        // Si está cargando, mostrar estado de carga
        if (provider.isLoading) {
          return _buildLoadingState();
        }
        
        // Si está actualizando, mostrar estado de actualización
        if (provider.isUpdating) {
          return _buildUpdatingState();
        }
        
        // Estado normal con datos
        return _buildNormalState(provider);
      },
    );
  }

  /// Construye estado de advertencia (datos en cache pero error de conexión)
  Widget _buildWarningState(RobustAsistenciaProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: DesignConstants.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: DesignConstants.warningOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: DesignConstants.warningOrange,
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos en Cache',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: DesignConstants.warningOrangeDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Mostrando datos anteriores. Intentando reconectar...',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: DesignConstants.textSecondary,
                  ),
                ),
                if (provider.lastDataUpdate != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Última actualización: ${_formatDateTime(provider.lastDataUpdate!)}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: DesignConstants.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildConnectionStatus(provider),
        ],
      ),
    );
  }

  /// Construye estado de error (sin datos disponibles)
  Widget _buildErrorState(RobustAsistenciaProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: DesignConstants.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: DesignConstants.errorRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: DesignConstants.errorRed,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Sin Datos Disponibles',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: DesignConstants.errorRedDark,
                  ),
                ),
              ),
              _buildConnectionStatus(provider),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            provider.errorMessage.isNotEmpty 
                ? provider.errorMessage 
                : 'No se pudieron cargar los datos. Verificando conexión...',
            style: TextStyle(
              fontSize: 12.sp,
              color: DesignConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: () => provider.forceRefresh(),
            icon: Icon(Icons.refresh, size: 16.w),
            label: Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignConstants.errorRed,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye estado de carga
  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: DesignConstants.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: DesignConstants.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(DesignConstants.primaryBlue),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Cargando datos...',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: DesignConstants.primaryBlueDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye estado de actualización
  Widget _buildUpdatingState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: DesignConstants.cyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: DesignConstants.cyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(DesignConstants.cyan),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Actualizando datos...',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: DesignConstants.cyanDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye estado normal
  Widget _buildNormalState(RobustAsistenciaProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: DesignConstants.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: DesignConstants.successGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: DesignConstants.successGreen,
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos Actualizados',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: DesignConstants.successGreenDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${provider.asistenciasDetalle.length} asistencias disponibles',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: DesignConstants.textSecondary,
                  ),
                ),
                if (provider.lastDataUpdate != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Última actualización: ${_formatDateTime(provider.lastDataUpdate!)}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: DesignConstants.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildConnectionStatus(provider),
        ],
      ),
    );
  }

  /// Construye el estado de conexión
  Widget _buildConnectionStatus(RobustAsistenciaProvider provider) {
    Color color;
    IconData icon;
    String tooltip;

    if (provider.isWebSocketConnected) {
      color = DesignConstants.successGreen;
      icon = Icons.wifi;
      tooltip = 'WebSocket conectado';
    } else if (provider.isPollingActive) {
      color = DesignConstants.warningOrange;
      icon = Icons.sync;
      tooltip = 'Usando polling de fallback';
    } else {
      color = DesignConstants.errorRed;
      icon = Icons.wifi_off;
      tooltip = 'Sin conexión';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 16.w,
          color: color,
        ),
      ),
    );
  }

  /// Formatea fecha y hora
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}

/// Widget compacto para mostrar estado de datos en header
class CompactDataStatusWidget extends StatelessWidget {
  const CompactDataStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RobustAsistenciaProvider>(
      builder: (context, provider, _) {
        Color color;
        IconData icon;
        String text;

        if (provider.hasError && provider.asistenciasDetalle.isEmpty) {
          color = DesignConstants.errorRed;
          icon = Icons.error_outline;
          text = 'Error';
        } else if (provider.hasError && provider.asistenciasDetalle.isNotEmpty) {
          color = DesignConstants.warningOrange;
          icon = Icons.warning_amber;
          text = 'Cache';
        } else if (provider.isLoading) {
          color = DesignConstants.primaryBlue;
          icon = Icons.hourglass_empty;
          text = 'Cargando';
        } else if (provider.isUpdating) {
          color = DesignConstants.cyan;
          icon = Icons.sync;
          text = 'Actualizando';
        } else {
          color = DesignConstants.successGreen;
          icon = Icons.check_circle;
          text = 'OK';
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12.w,
                color: color,
              ),
              SizedBox(width: 4.w),
              Text(
                text,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
