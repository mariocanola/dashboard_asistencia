/// Configuración de la aplicación
class AppConfig {
  /// Configurado para usar solo WebSocket real con Pusher
  /// Los datos mock han sido eliminados
  static const bool useMockWebSocket = false;

  /// Cambiar a true para mostrar logs detallados
  static const bool enableDebugLogs = true;

  /// Configuración de la aplicación
  static const String appName = 'Dashboard de Asistencia SENA';
  static const String appVersion = '1.0.0';

  /// Información de contacto para soporte
  static const String supportEmail = 'soporte@dashboard.com';

  /// Configuración de notificaciones
  static const bool enableNotifications = true;
  static const int notificationTimeoutSeconds = 5;

  /// Configuración de actualización automática
  static const bool enableAutoRefresh = true;
  static const int autoRefreshIntervalSeconds = 30;
}
