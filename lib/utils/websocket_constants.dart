/// Constantes para la configuración de WebSocket
class WebSocketConstants {
  /// Configuración del servidor WebSocket
  static const String host = '192.168.1.2';
  static const int port = 8080;
  static const String cluster = 'mt1';
  static const String key = 'local';

  /// URL completa del WebSocket
  static const String wsUrl = 'ws://$host:$port/app/$key';

  /// Nombres de canales
  static const String canalAsistencias = 'asistencias';
  static const String canalQrScans = 'qr-scans';

  /// Lista de todos los canales
  static const List<String> canales = [
    canalAsistencias,
    canalQrScans,
  ];

  /// Nombres de eventos (con punto al inicio según formato Pusher/Laravel Echo)
  static const String eventoNuevaAsistencia = '.NuevaAsistenciaRegistrada';
  static const String eventoQrScanned = '.QrScanned';

  /// Lista de todos los eventos
  static const List<String> eventos = [
    eventoNuevaAsistencia,
    eventoQrScanned,
  ];

  /// Configuración de reconexión
  static const int maxReconnectAttempts = 5;
  static const int reconnectDelaySeconds = 3;
  static const int heartbeatIntervalSeconds = 30;
  static const int connectionTimeoutSeconds = 10;

  /// Estados de conexión
  static const String estadoConectado = 'conectado';
  static const String estadoDesconectado = 'desconectado';
  static const String estadoConectando = 'conectando';
  static const String estadoError = 'error';
  static const String estadoReconectando = 'reconectando';

  /// Lista de estados válidos
  static const List<String> estados = [
    estadoConectado,
    estadoDesconectado,
    estadoConectando,
    estadoError,
    estadoReconectando,
  ];
}
