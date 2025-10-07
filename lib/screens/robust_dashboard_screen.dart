import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/robust_asistencia_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/robust_dashboard_widgets.dart';
import '../widgets/robust_connection_status_widget.dart';
import '../widgets/resilient_data_status_widget.dart';
import '../widgets/fichas_en_formacion_widget.dart';
import '../widgets/ultra_fast_asistencias_widget.dart';
import '../utils/constants.dart';

/// Dashboard screen optimizado con provider robusto y manejo resiliente de errores
class RobustDashboardScreen extends StatelessWidget {
  const RobustDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignConstants.backgroundLight,
      body: SafeArea(
        child: Consumer<RobustAsistenciaProvider>(
          builder: (context, provider, _) {
            // Detectar tipo de pantalla
            final screenSize = MediaQuery.of(context).size;
            final isTV = screenSize.width >= 1920;
            final isUltraWide = screenSize.width >= 2560;
            final isLargeDesktop = screenSize.width >= 1440;
            final isDesktop = screenSize.width >= 1024;
            final isTablet = screenSize.width >= 768;
            final isMobile = screenSize.width < 768;

            // Configuración responsiva
            final basePadding = isTV ? 32.w : isUltraWide ? 24.w : isLargeDesktop ? 20.w : isDesktop ? 16.w : isTablet ? 12.w : 8.w;
            final maxWidth = isTV ? 2400.w : isUltraWide ? 2000.w : isLargeDesktop ? 1600.w : isDesktop ? 1200.w : double.infinity;
            final columnSpacing = isTV ? 24.w : isUltraWide ? 20.w : isLargeDesktop ? 16.w : isDesktop ? 12.w : isTablet ? 8.w : 4.w;

            // Flex ratios responsivos
            int leftColumnFlex = isTV ? 3 : isUltraWide ? 2 : isLargeDesktop ? 2 : isDesktop ? 2 : isTablet ? 2 : 1;
            int rightColumnFlex = isTV ? 2 : isUltraWide ? 2 : isLargeDesktop ? 2 : isDesktop ? 2 : isTablet ? 1 : 1;

            return Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: EdgeInsets.all(basePadding),
              child: isMobile ? _buildMobileLayout(provider, basePadding) : _buildDesktopLayout(
                provider, 
                basePadding, 
                columnSpacing, 
                leftColumnFlex, 
                rightColumnFlex
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construye el layout para desktop/tablet
  Widget _buildDesktopLayout(
    RobustAsistenciaProvider provider,
    double basePadding,
    double columnSpacing,
    int leftColumnFlex,
    int rightColumnFlex,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda - Contenido principal
        Expanded(
          flex: leftColumnFlex,
          child: Column(
            children: [
              // Header con estado de conexión
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardHeader(
                    fecha: DateTime.now().toLocal().toString().split(' ')[0],
                    hora: DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8),
                    jornada: _getCurrentJornada(),
                    isUpdating: provider.isUpdating,
                  ),
                  const RobustConnectionStatusWidget(),
                ],
              ),
              SizedBox(height: basePadding),
              
              // KPI principal
              const RobustMainKPICardWidget(),
              SizedBox(height: basePadding),
              
              // Métricas complementarias
              const RobustMetricsCardsWidget(),
              SizedBox(height: basePadding),
              
              // Estado de datos resiliente
              const ResilientDataStatusWidget(),
              SizedBox(height: basePadding),
              
              // Widget de asistencias ultra-rápido (mantener compatibilidad)
              const UltraFastAsistenciasWidget(),
            ],
          ),
        ),
        
        SizedBox(width: columnSpacing),
        
        // Columna derecha - Fichas en formación
        Expanded(
          flex: rightColumnFlex,
          child: Column(
            children: [
              // Header de la sección
              Row(
                children: [
                  Icon(
                    Icons.school,
                    size: 24.w,
                    color: DesignConstants.primaryBlue,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Fichas en Formación',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: DesignConstants.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const CompactConnectionStatusWidget(),
                ],
              ),
              SizedBox(height: basePadding),
              
              // Widget de fichas en formación
              const FichasEnFormacionWidget(),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye el layout para móvil
  Widget _buildMobileLayout(RobustAsistenciaProvider provider, double basePadding) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header con estado de conexión
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DashboardHeader(
                fecha: DateTime.now().toLocal().toString().split(' ')[0],
                hora: DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8),
                jornada: _getCurrentJornada(),
                isUpdating: provider.isUpdating,
              ),
              const CompactConnectionStatusWidget(),
            ],
          ),
          SizedBox(height: basePadding),
          
          // KPI principal
          const RobustMainKPICardWidget(),
          SizedBox(height: basePadding),
          
          // Métricas complementarias
          const RobustMetricsCardsWidget(),
          SizedBox(height: basePadding),
          
          // Estado de datos resiliente
          const ResilientDataStatusWidget(),
          SizedBox(height: basePadding),
          
          // Fichas en formación
          Row(
            children: [
              Icon(
                Icons.school,
                size: 20.w,
                color: DesignConstants.primaryBlue,
              ),
              SizedBox(width: 8.w),
              Text(
                'Fichas en Formación',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: DesignConstants.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: basePadding),
          const FichasEnFormacionWidget(),
          SizedBox(height: basePadding),
          
          // Widget de asistencias ultra-rápido
          const UltraFastAsistenciasWidget(),
        ],
      ),
    );
  }

  /// Obtiene la jornada actual
  String _getCurrentJornada() {
    final jornadaActual = JornadaConstants.getJornadaString(JornadaConstants.getJornadaActual());
    return jornadaActual.isEmpty ? 'Fuera de Jornada' : jornadaActual;
  }
}

/// Widget de estado de conexión en tiempo real para debugging
class DebugConnectionWidget extends StatelessWidget {
  const DebugConnectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RobustAsistenciaProvider>(
      builder: (context, provider, _) {
        final stats = provider.getServiceStats();
        
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
                'Debug - Estado de Conexión',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: DesignConstants.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              
              // Estado WebSocket
              _buildDebugRow('WebSocket', provider.isWebSocketConnected ? 'Conectado' : 'Desconectado'),
              _buildDebugRow('Polling', provider.isPollingActive ? 'Activo' : 'Inactivo'),
              _buildDebugRow('Actualizando', provider.isUpdating ? 'Sí' : 'No'),
              _buildDebugRow('Con Error', provider.hasError ? 'Sí' : 'No'),
              
              SizedBox(height: 8.h),
              
              // Estadísticas del servicio
              Text(
                'Estadísticas del Servicio:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: DesignConstants.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              
              Text(
                'Estado: ${stats['webSocketStats']['connectionState']}',
                style: TextStyle(fontSize: 12.sp, color: DesignConstants.textSecondary),
              ),
              Text(
                'Intentos de reconexión: ${stats['webSocketStats']['reconnectAttempts']}',
                style: TextStyle(fontSize: 12.sp, color: DesignConstants.textSecondary),
              ),
              Text(
                'Cache de eventos: ${stats['webSocketStats']['eventCacheSize']}',
                style: TextStyle(fontSize: 12.sp, color: DesignConstants.textSecondary),
              ),
              
              if (provider.lastDataUpdate != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'Última actualización: ${_formatDateTime(provider.lastDataUpdate!)}',
                  style: TextStyle(fontSize: 12.sp, color: DesignConstants.textSecondary),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Construye una fila de debug
  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: DesignConstants.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: DesignConstants.textSecondary,
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
