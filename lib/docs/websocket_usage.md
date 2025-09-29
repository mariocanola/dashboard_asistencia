# Guía de Uso del Sistema WebSocket

## Descripción General

El sistema WebSocket implementado permite recibir notificaciones en tiempo real del sistema de asistencias. Está diseñado siguiendo los principios **SRP** (Single Responsibility Principle), **KISS** (Keep It Simple, Stupid) y **DRY** (Don't Repeat Yourself).

## Arquitectura

### Archivos Principales

- `lib/utils/websocket_constants.dart` - Constantes de configuración
- `lib/models/websocket_event.dart` - Modelo de eventos
- `lib/services/websocket_service.dart` - Servicio principal
- `lib/widgets/websocket_status_widget.dart` - Widget de estado
- `lib/providers/asistencia_provider.dart` - Integración con Provider

### Configuración

```dart
// Configuración del servidor WebSocket
static const String host = '127.0.0.1';
static const int port = 6001;
static const String cluster = 'mt1';
static const String key = 'local';
```

### Canales

- `asistencias` - Para eventos de nueva asistencia registrada
- `qr-scans` - Para eventos de QR escaneado

### Eventos

- `NuevaAsistenciaRegistrada` - Cuando se registra una nueva asistencia
- `QrScanned` - Cuando se escanea un código QR

## Uso Básico

### 1. Inicialización Automática

El WebSocket se inicializa automáticamente cuando se crea el `AsistenciaProvider`:

```dart
// En main.dart
ChangeNotifierProvider(
  create: (_) => AsistenciaProvider(apiService: apiService),
),
```

### 2. Verificar Estado de Conexión

```dart
Consumer<AsistenciaProvider>(
  builder: (context, provider, child) {
    if (provider.isWebSocketConnected) {
      // WebSocket conectado
      print('Estado: ${provider.webSocketState}');
    }
  },
)
```

### 3. Mostrar Estado en UI

```dart
// Agregar el widget de estado en tu pantalla
const WebSocketStatusWidget(),
```

### 4. Control Manual

```dart
// Conectar manualmente
await provider.conectarWebSocket();

// Desconectar manualmente
await provider.desconectarWebSocket();
```

## Características

### Reconexión Automática

- Máximo 5 intentos de reconexión
- Delay de 3 segundos entre intentos
- Reconexión automática en caso de pérdida de conexión

### Notificaciones Locales

- Notificaciones automáticas cuando llegan eventos
- Títulos y mensajes personalizados según el tipo de evento
- Configuración automática de notificaciones

### Heartbeat

- Ping automático cada 30 segundos
- Mantiene la conexión viva
- Detecta desconexiones rápidamente

### Manejo de Errores

- Logging detallado para debugging
- Estados de conexión claros
- Recuperación automática de errores

## Estados de Conexión

1. **conectado** - Conexión establecida y funcionando
2. **desconectado** - Sin conexión activa
3. **conectando** - Estableciendo conexión
4. **error** - Error en la conexión
5. **reconectando** - Intentando reconectar

## Eventos Recibidos

### Nueva Asistencia

```dart
{
  "event": "NuevaAsistenciaRegistrada",
  "channel": "asistencias",
  "data": {
    "ficha_id": "12345",
    "aprendiz_id": "67890",
    "programa": "Técnico en Sistemas",
    "jornada": "MAÑANA"
  }
}
```

### QR Escaneado

```dart
{
  "event": "QrScanned",
  "channel": "qr-scans",
  "data": {
    "ficha_id": "12345",
    "aprendiz_id": "67890",
    "programa": "Técnico en Sistemas",
    "jornada": "MAÑANA"
  }
}
```

## Personalización

### Modificar Configuración

Edita `lib/utils/websocket_constants.dart`:

```dart
// Cambiar host y puerto
static const String host = 'tu-servidor.com';
static const int port = 8080;

// Agregar nuevos canales
static const List<String> canales = [
  'asistencias',
  'qr-scans',
  'tu-nuevo-canal',
];
```

### Agregar Nuevos Eventos

1. Agregar constantes en `websocket_constants.dart`
2. Actualizar `WebSocketEvent` en `websocket_event.dart`
3. Manejar en `AsistenciaProvider`

### Personalizar Notificaciones

Modifica el método `_showNotification` en `websocket_service.dart`:

```dart
Future<void> _showNotification(WebSocketEvent event) async {
  // Tu lógica personalizada aquí
}
```

## Debugging

### Logs Disponibles

El sistema genera logs detallados con emojis para fácil identificación:

- ✅ Conexión exitosa
- ❌ Errores
- 📨 Eventos recibidos
- 🔌 Cambios de estado
- 🔄 Reconexiones

### Verificar Conexión

```dart
// Verificar estado
print('WebSocket State: ${provider.webSocketState}');
print('Is Connected: ${provider.isWebSocketConnected}');
```

## Consideraciones de Rendimiento

- Conexión única por aplicación (Singleton)
- Streams eficientes con broadcast
- Actualización de UI solo cuando es necesario
- Limpieza automática de recursos

## Seguridad

- Validación de datos recibidos
- Manejo seguro de errores
- No exposición de datos sensibles en logs
- Timeouts para evitar conexiones colgadas

