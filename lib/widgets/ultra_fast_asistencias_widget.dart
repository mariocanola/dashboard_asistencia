import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/asistencia_detalle_model.dart';
import '../models/ficha_estadisticas_model.dart';
import '../providers/hybrid_asistencia_provider.dart';
import '../utils/constants.dart';
import 'estadisticas_generales_widget.dart';

/// Widget ultra-optimizado para manejar miles de asistencias en tiempo real
/// Máximo 5 segundos de actualización, optimizado para alta carga
class UltraFastAsistenciasWidget extends StatefulWidget {
  const UltraFastAsistenciasWidget({super.key});

  @override
  State<UltraFastAsistenciasWidget> createState() =>
      _UltraFastAsistenciasWidgetState();
}

class _UltraFastAsistenciasWidgetState
    extends State<UltraFastAsistenciasWidget> {
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
      // Inicialización simplificada - ahora usamos HybridAsistenciaProvider
      debugPrint('✅ UltraFastAsistenciasWidget inicializado');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HybridAsistenciaProvider>(
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
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(DesignConstants.primaryBlue),
          ),
          SizedBox(height: 16.h),
          Text(
            'Cargando asistencias...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: DesignConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget de estado de error
  Widget _buildErrorState(String error) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red[600],
            size: 48.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error al cargar asistencias',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              final provider = context.read<HybridAsistenciaProvider>();
              provider.cargarDatos();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignConstants.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Widget de estado vacío
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            color: Colors.grey[400],
            size: 48.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'No hay asistencias registradas',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Widget principal ultra-optimizado
  Widget _buildUltraFastContent(
      List<AsistenciaDetalle> asistencias, HybridAsistenciaProvider provider) {
    // Agrupar asistencias por ficha - optimizado
    final Map<String, List<AsistenciaDetalle>> porFicha = {};
    for (var asistencia in asistencias) {
      porFicha.putIfAbsent(asistencia.ficha, () => []).add(asistencia);
    }

    // Crear estadísticas de fichas
    final estadisticasFichas = porFicha.entries.map((entry) {
      return FichaEstadisticas.fromAsistencias(
        ficha: entry.key,
        asistencias: entry.value,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con estadísticas generales
        const EstadisticasGeneralesWidget(),
        SizedBox(height: 16.h),

        // Lista de fichas ultra-optimizada con altura fija para evitar constraints no acotados
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 400.h),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: estadisticasFichas.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final estadistica = estadisticasFichas[index];
              return _buildUltraFastFichaCard(estadistica);
            },
          ),
        ),
      ],
    );
  }

  /// Widget de tarjeta de ficha ultra-optimizada
  Widget _buildUltraFastFichaCard(FichaEstadisticas estadistica) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: estadistica.estadoColor.withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          // Icono de estado
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: estadistica.estadoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              estadistica.flechaIcon,
              color: estadistica.estadoColor,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),

          // Información de la ficha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ficha ${estadistica.ficha}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: DesignConstants.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${estadistica.totalAprendices} aprendices',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: DesignConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Porcentaje de variación
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    estadistica.flechaIcon,
                    color: estadistica.flechaColor,
                    size: 16.w,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${estadistica.porcentajeVariacion.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: estadistica.flechaColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: estadistica.estadoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  estadistica.estadoGeneral,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: estadistica.estadoColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
