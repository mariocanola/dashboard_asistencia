import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/websocket_pusher_service.dart';
import '../utils/websocket_constants.dart';

/// Widget que muestra el estado detallado de la conexión WebSocket
class WebSocketConnectionStatus extends StatefulWidget {
  const WebSocketConnectionStatus({super.key});

  @override
  State<WebSocketConnectionStatus> createState() =>
      _WebSocketConnectionStatusState();
}

class _WebSocketConnectionStatusState extends State<WebSocketConnectionStatus> {
  final WebSocketPusherService _webSocketService = WebSocketPusherService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: _webSocketService.connectionStateStream,
      builder: (context, snapshot) {
        final estado = snapshot.data ?? WebSocketConstants.estadoDesconectado;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _getBackgroundColor(estado),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: _getBorderColor(estado), width: 1),
            boxShadow: [
              BoxShadow(
                color: _getShadowColor(estado).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de estado animado
              _buildStatusIndicator(estado),
              SizedBox(width: 8.w),

              // Texto del estado
              Text(
                _getStatusText(estado),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(estado),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye el indicador de estado
  Widget _buildStatusIndicator(String estado) {
    switch (estado) {
      case WebSocketConstants.estadoConectado:
        return Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );

      case WebSocketConstants.estadoConectando:
      case WebSocketConstants.estadoReconectando:
        return SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFF59E0B)),
          ),
        );

      case WebSocketConstants.estadoError:
        return Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        );

      default:
        return Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: const Color(0xFF6B7280),
            shape: BoxShape.circle,
          ),
        );
    }
  }

  /// Obtiene el color de fondo según el estado
  Color _getBackgroundColor(String estado) {
    switch (estado) {
      case WebSocketConstants.estadoConectado:
        return const Color(0xFFECFDF5);
      case WebSocketConstants.estadoConectando:
      case WebSocketConstants.estadoReconectando:
        return const Color(0xFFFEF3C7);
      case WebSocketConstants.estadoError:
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  /// Obtiene el color del borde según el estado
  Color _getBorderColor(String estado) {
    switch (estado) {
      case WebSocketConstants.estadoConectado:
        return const Color(0xFF10B981);
      case WebSocketConstants.estadoConectando:
      case WebSocketConstants.estadoReconectando:
        return const Color(0xFFF59E0B);
      case WebSocketConstants.estadoError:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// Obtiene el color de la sombra según el estado
  Color _getShadowColor(String estado) {
    switch (estado) {
      case WebSocketConstants.estadoConectado:
        return const Color(0xFF10B981);
      case WebSocketConstants.estadoConectando:
      case WebSocketConstants.estadoReconectando:
        return const Color(0xFFF59E0B);
      case WebSocketConstants.estadoError:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// Obtiene el color del texto según el estado
  Color _getTextColor(String estado) {
    switch (estado) {
      case WebSocketConstants.estadoConectado:
        return const Color(0xFF065F46);
      case WebSocketConstants.estadoConectando:
      case WebSocketConstants.estadoReconectando:
        return const Color(0xFF92400E);
      case WebSocketConstants.estadoError:
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFF374151);
    }
  }

  /// Obtiene el texto del estado
  String _getStatusText(String estado) {
    switch (estado) {
      case WebSocketConstants.estadoConectado:
        return 'Tiempo Real Activo';
      case WebSocketConstants.estadoConectando:
        return 'Conectando...';
      case WebSocketConstants.estadoReconectando:
        return 'Reconectando...';
      case WebSocketConstants.estadoError:
        return 'Error de Conexión';
      case WebSocketConstants.estadoDesconectado:
        return 'Desconectado';
      default:
        return 'Estado Desconocido';
    }
  }
}
