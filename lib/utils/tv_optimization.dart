import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuraciones y optimizaciones específicas para TV
class TVOptimization {
  /// Configura la aplicación para modo TV
  static void configureTVMode() {
    // Oculta la barra de estado y navegación para pantalla completa
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // Fuerza orientación horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Desactiva el overscan (márgenes de seguridad de TV)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }
  
  /// Detecta si la app está corriendo en un dispositivo TV
  static bool isTV() {
    // En una implementación real, deberías usar platform channels
    // para detectar android.software.leanback
    return true; // Por ahora asumimos que siempre es TV
  }
  
  /// Obtiene el tamaño de pantalla recomendado para TV
  static Size getTVScreenSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Aplicar márgenes de seguridad para TV (5% en cada lado)
    final safeWidth = size.width * 0.9;
    final safeHeight = size.height * 0.9;
    
    return Size(safeWidth, safeHeight);
  }
  
  /// Calcula el tamaño de fuente apropiado para TV
  static double getTVFontSize(double baseSize) {
    // Las fuentes deben ser más grandes en TV debido a la distancia de visualización
    return baseSize * 1.5;
  }
  
  /// Obtiene el padding recomendado para elementos en TV
  static EdgeInsets getTVPadding({
    double horizontal = 16.0,
    double vertical = 12.0,
  }) {
    // Mayor padding para mejor legibilidad en TV
    return EdgeInsets.symmetric(
      horizontal: horizontal * 1.5,
      vertical: vertical * 1.5,
    );
  }
}

/// Widget que aplica márgenes de seguridad para TV
class TVSafeArea extends StatelessWidget {
  final Widget child;
  final double marginPercentage;
  
  const TVSafeArea({
    Key? key,
    required this.child,
    this.marginPercentage = 0.05, // 5% de margen por defecto
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (!TVOptimization.isTV()) {
      return child;
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalMargin = constraints.maxWidth * marginPercentage;
        final verticalMargin = constraints.maxHeight * marginPercentage;
        
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalMargin,
            vertical: verticalMargin,
          ),
          child: child,
        );
      },
    );
  }
}

/// Configuración de rendimiento para TV
class TVPerformanceConfig {
  /// Optimiza las animaciones para TV
  static void optimizeAnimations() {
    // Reduce la duración de las animaciones para mejor respuesta
    // en controles remotos
  }
  
  /// Configura el caché de imágenes para TV
  static void configureImageCache() {
    // TV generalmente tiene más memoria disponible
    PaintingBinding.instance.imageCache.maximumSize = 200;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20; // 200 MB
  }
}