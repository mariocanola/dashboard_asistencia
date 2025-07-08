import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/constants.dart';

class EstadisticasCard extends StatelessWidget {
  final String titulo;
  final Widget child;
  final List<Widget>? acciones;
  final double? height;
  final bool conBorde;

  const EstadisticasCard({
    super.key,
    required this.titulo,
    required this.child,
    this.acciones,
    this.height,
    this.conBorde = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: conBorde
            ? Border.all(color: Colors.grey.shade300, width: 1.w)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado de la tarjeta
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1.w,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(AppThemes.primaryColor),
                  ),
                ),
                if (acciones != null) ...acciones!,
              ],
            ),
          ),
          
          // Contenido de la tarjeta
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar un indicador de carga
class LoadingIndicator extends StatelessWidget {
  final String mensaje;
  
  const LoadingIndicator({
    super.key,
    this.mensaje = 'Cargando datos...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0066B2)),
          ),
          SizedBox(height: 16.h),
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar un mensaje de error
class ErrorMessage extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onReintentar;
  
  const ErrorMessage({
    super.key,
    required this.mensaje,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.red.shade700,
              ),
            ),
            if (onReintentar != null) ...[
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: onReintentar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
