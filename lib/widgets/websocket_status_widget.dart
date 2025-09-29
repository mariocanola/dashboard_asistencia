import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asistencia_provider.dart';
import '../utils/websocket_constants.dart';
import '../utils/constants.dart';

/// Widget para mostrar el estado de conexión WebSocket
class WebSocketStatusWidget extends StatelessWidget {
  const WebSocketStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AsistenciaProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getStatusColor(provider.webSocketState),
            borderRadius: BorderRadius.circular(20),
            boxShadow: DesignConstants.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(provider.webSocketState),
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(provider.webSocketState),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (provider.webSocketState ==
                  WebSocketConstants.estadoError) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => provider.conectarWebSocket(),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Obtiene el color según el estado de conexión
  Color _getStatusColor(String state) {
    switch (state) {
      case WebSocketConstants.estadoConectado:
        return DesignConstants.successGreen;
      case WebSocketConstants.estadoConectando:
      case WebSocketConstants.estadoReconectando:
        return DesignConstants.warningOrange;
      case WebSocketConstants.estadoError:
        return DesignConstants.errorRed;
      case WebSocketConstants.estadoDesconectado:
      default:
        return DesignConstants.textSecondary;
    }
  }

  /// Obtiene el icono según el estado de conexión
  IconData _getStatusIcon(String state) {
    switch (state) {
      case WebSocketConstants.estadoConectado:
        return Icons.wifi;
      case WebSocketConstants.estadoConectando:
      case WebSocketConstants.estadoReconectando:
        return Icons.wifi_find;
      case WebSocketConstants.estadoError:
        return Icons.wifi_off;
      case WebSocketConstants.estadoDesconectado:
      default:
        return Icons.wifi_off;
    }
  }

  /// Obtiene el texto según el estado de conexión
  String _getStatusText(String state) {
    switch (state) {
      case WebSocketConstants.estadoConectado:
        return 'Conectado';
      case WebSocketConstants.estadoConectando:
        return 'Conectando...';
      case WebSocketConstants.estadoReconectando:
        return 'Reconectando...';
      case WebSocketConstants.estadoError:
        return 'Error - Toca para reintentar';
      case WebSocketConstants.estadoDesconectado:
      default:
        return 'Desconectado';
    }
  }
}

