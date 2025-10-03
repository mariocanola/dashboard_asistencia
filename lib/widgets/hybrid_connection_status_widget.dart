import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/hybrid_asistencia_provider.dart';

/// Widget que muestra el estado de conexión híbrida
/// Muestra "WebSocket Activo ✅" o "Usando Polling ⏳"
class HybridConnectionStatusWidget extends StatelessWidget {
  const HybridConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HybridAsistenciaProvider>(
      builder: (context, provider, _) {
        final isWebSocketActive = provider.isWebSocketActive;
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isWebSocketActive ? Colors.green[100] : Colors.orange[100],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isWebSocketActive ? Colors.green : Colors.orange,
              width: 1.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWebSocketActive ? Icons.wifi_rounded : Icons.cloud_sync_rounded,
                color: isWebSocketActive ? Colors.green[700] : Colors.orange[700],
                size: 18.w,
              ),
              SizedBox(width: 8.w),
              Text(
                isWebSocketActive ? "WebSocket Activo ✅" : "Usando Polling ⏳",
                style: TextStyle(
                  color: isWebSocketActive ? Colors.green[700] : Colors.orange[700],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget compacto para mostrar el estado de conexión
class CompactHybridConnectionWidget extends StatelessWidget {
  const CompactHybridConnectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HybridAsistenciaProvider>(
      builder: (context, provider, _) {
        final isWebSocketActive = provider.isWebSocketActive;
        
        return Tooltip(
          message: isWebSocketActive ? "WebSocket Activo ✅" : "Usando Polling ⏳",
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: isWebSocketActive ? Colors.green[100] : Colors.orange[100],
              shape: BoxShape.circle,
              border: Border.all(
                color: isWebSocketActive ? Colors.green : Colors.orange,
                width: 1.w,
              ),
            ),
            child: Icon(
              isWebSocketActive ? Icons.wifi_rounded : Icons.cloud_sync_rounded,
              color: isWebSocketActive ? Colors.green[700] : Colors.orange[700],
              size: 16.w,
            ),
          ),
        );
      },
    );
  }
}

/// Widget de estadísticas del servicio híbrido
class HybridServiceStatsWidget extends StatelessWidget {
  const HybridServiceStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HybridAsistenciaProvider>(
      builder: (context, provider, _) {
        final stats = provider.getServiceStats();
        final lastUpdate = provider.lastDataUpdate;
        
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado del Servicio Híbrido',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12.h),
              
              // Estado de conexión
              Row(
                children: [
                  Icon(
                    provider.isWebSocketActive ? Icons.wifi_rounded : Icons.cloud_sync_rounded,
                    color: provider.isWebSocketActive ? Colors.green : Colors.orange,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    stats['connectionMode'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: provider.isWebSocketActive ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8.h),
              
              // Última actualización
              if (lastUpdate != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Colors.grey[600],
                      size: 16.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Última actualización: ${_formatTime(lastUpdate)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
              ],
              
              // Botón de reconexión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => provider.reconnect(),
                  icon: Icon(Icons.refresh_rounded, size: 16.w),
                  label: Text('Reconectar', style: TextStyle(fontSize: 12.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[700],
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}m';
    } else {
      return 'hace ${difference.inHours}h';
    }
  }
}
