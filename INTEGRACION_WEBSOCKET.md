# 🚀 Integración de WebSocket y Endpoints de Asistencias

## 📋 Resumen

Se ha actualizado la aplicación Flutter para integrarse correctamente con el backend Laravel y sus endpoints de asistencias con WebSocket en tiempo real usando Laravel Reverb.

## 🔧 Cambios Realizados

### 1. **Actualización de Constantes** (`lib/utils/constants.dart`)

Se agregaron los nuevos endpoints según el backend:

```dart
// Nuevos endpoints de asistencias
static const String asistenciaEntrada = '/asistencia/entrada';
static const String asistenciaSalida = '/asistencia/salida';
static const String asistenciaJornada = '/asistencia/jornada';
static const String asistenciaFichas = '/asistencia/fichas';
```

### 2. **Actualización de WebSocket Constants** (`lib/utils/websocket_constants.dart`)

Corregido el formato de eventos para que coincida con Laravel Reverb:

```dart
// Eventos con punto al inicio (formato Laravel Echo/Pusher)
static const String eventoNuevaAsistencia = '.NuevaAsistenciaRegistrada';
static const String eventoQrScanned = '.QrScanned';
```

### 3. **Nuevo Modelo AsistenciaDetalle** (`lib/models/asistencia_detalle_model.dart`)

Creado modelo que mapea exactamente la respuesta del endpoint `/api/asistencia/jornada`:

**Campos del modelo:**
- `id`: ID de la asistencia
- `aprendiz`: Nombre completo del aprendiz
- `numeroDocumento`: Número de documento
- `horaIngreso`: Hora de entrada
- `horaSalida`: Hora de salida (nullable)
- `ficha`: Número de ficha
- `jornada`: Nombre de la jornada (Mañana/Tarde/Noche)
- `jornadaId`: ID de la jornada
- `fecha`: Fecha de la asistencia
- `estado`: Estado (completa/pendiente)

**Modelo de respuesta completa:**
```dart
class AsistenciaJornadaResponse {
  final String status;
  final String fecha;
  final int totalAsistencias;
  final List<AsistenciaDetalle> asistencias;
  final Map<String, List<AsistenciaDetalle>> porJornada;
}
```

### 4. **Actualización de WebSocketEvent** (`lib/models/websocket_event.dart`)

Mejorado para soportar el formato de datos del backend:

**Nuevos getters:**
- `asistenciaId`: ID de la asistencia registrada
- `aprendizNombre`: Nombre del aprendiz
- `estadoAsistencia`: Estado (entrada/salida)
- `timestampEvento`: Timestamp del evento
- `tipo`: Tipo de evento

**Compatibilidad:**
- Soporta eventos con y sin punto al inicio
- Mapea correctamente los datos según formato del backend

### 5. **Actualización de ApiService** (`lib/services/api_service.dart`)

Implementado método para consumir el nuevo endpoint:

```dart
Future<AsistenciaJornadaResponse> getAsistenciasPorJornada({
  int? jornadaId,
  DateTime? fecha,
})
```

**Características:**
- Parámetros opcionales para filtrar por jornada y fecha
- Formato de fecha: `yyyy-MM-dd`
- Construcción dinámica de query parameters
- Manejo robusto de errores

### 6. **Actualización de AsistenciaProvider** (`lib/providers/asistencia_provider.dart`)

**Nuevas funcionalidades:**

1. **Lista de asistencias detalladas:**
   ```dart
   List<AsistenciaDetalle> get asistenciasDetalle
   ```

2. **Últimas asistencias en tiempo real:**
   ```dart
   List<WebSocketEvent> get ultimasAsistenciasWebSocket
   ```

3. **Procesamiento mejorado de eventos WebSocket:**
   - Almacena las últimas 10 asistencias recibidas
   - Logs detallados de cada evento
   - Actualización automática de datos

### 7. **Nuevo Widget de Asistencias en Tiempo Real** (`lib/widgets/asistencias_tiempo_real_widget.dart`)

**Características:**
- ✅ Muestra las últimas 10 asistencias en tiempo real
- 🟢 Indicador de conexión WebSocket (En vivo/Desconectado)
- 🎨 Diseño moderno con gradientes y sombras
- 📊 Diferenciación visual entre entrada (verde) y salida (rojo)
- ⏰ Muestra hora exacta de registro
- 📱 Información completa: aprendiz, ficha, jornada, estado

**Estados visuales:**
- **Entrada**: Icono de login, color verde
- **Salida**: Icono de logout, color rojo
- **Sin asistencias**: Mensaje de espera con icono

### 8. **Actualización de Dashboard** (`lib/screens/dashboard_screen.dart`)

Agregada nueva sección "Actividad Reciente" que muestra:
- Widget de asistencias en tiempo real
- Integración con el flujo visual del dashboard
- Posicionada estratégicamente entre gráficos y fichas

## 📡 Flujo de Datos

### Carga Inicial
```
1. AsistenciaProvider se inicializa
2. Carga datos desde API:
   - GET /api/asistencia/jornada
   - GET /api/fichas-caracterizacion/all
3. Conecta WebSocket al servidor Reverb
4. Se suscribe al canal 'asistencias'
```

### Actualización en Tiempo Real
```
1. Backend registra asistencia (entrada/salida)
2. Laravel dispara evento NuevaAsistenciaRegistrada
3. Reverb transmite al canal 'asistencias'
4. Flutter recibe el evento via WebSocket
5. AsistenciaProvider procesa el evento:
   - Agrega a lista de últimas asistencias
   - Actualiza datos desde API
   - Notifica a listeners (UI)
6. Widgets se actualizan automáticamente:
   - AsistenciasTiempoRealWidget
   - Estadísticas
   - Gráficos
```

## 🎯 Formato de Evento WebSocket

El backend envía eventos en este formato:

```json
{
  "event": ".NuevaAsistenciaRegistrada",
  "channel": "asistencias",
  "data": {
    "id": 123,
    "aprendiz": "Juan Pérez García",
    "estado": "entrada",
    "timestamp": "2025-09-30T08:30:00.000000Z",
    "jornada": "Mañana",
    "ficha": "2563478",
    "tipo": "nueva_asistencia"
  }
}
```

## 📱 UI/UX

### Widget de Asistencias en Tiempo Real

**Header:**
- Icono con gradiente verde
- Título "Asistencias en Tiempo Real"
- Indicador de estado de conexión

**Lista de Asistencias:**
- Diseño tipo card con bordes redondeados
- Color de fondo según estado (entrada/salida)
- Información organizada:
  - Izquierda: Icono y datos del aprendiz
  - Derecha: Badge de estado y hora

**Estado Vacío:**
- Icono de reloj
- Mensaje: "Esperando nuevas asistencias..."

## ⚙️ Configuración Requerida

### Backend (Laravel)

**Archivo `.env`:**
```env
QUEUE_CONNECTION=sync
BROADCAST_DRIVER=reverb
REVERB_APP_ID=local
REVERB_APP_KEY=local
REVERB_APP_SECRET=local
REVERB_HOST=127.0.0.1
REVERB_PORT=8080
REVERB_SCHEME=http
```

**Iniciar Reverb:**
```bash
php artisan reverb:start
```

### Frontend (Flutter)

**Archivo `lib/utils/constants.dart`:**
```dart
static const String baseUrl = 'http://TU_IP:8000/api';
```

**Archivo `lib/utils/websocket_constants.dart`:**
```dart
static const String host = 'TU_IP';
static const int port = 8080;
static const String key = 'local';
```

⚠️ **Importante:** Reemplaza `TU_IP` con la IP de tu servidor Laravel.

## 🧪 Pruebas

### 1. Probar Endpoint de Asistencias

```bash
curl -X GET "http://localhost:8000/api/asistencia/jornada?fecha=2025-09-30" \
  -H "Accept: application/json"
```

### 2. Registrar Entrada (Dispara WebSocket)

```bash
curl -X POST http://localhost:8000/api/asistencia/entrada \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "instructor_ficha_id": 1,
    "aprendiz_ficha_id": 1,
    "evidencia_id": null
  }'
```

### 3. Registrar Salida (Dispara WebSocket)

```bash
curl -X POST http://localhost:8000/api/asistencia/salida \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "aprendiz_ficha_id": 1
  }'
```

### 4. Usar Comando Artisan

```bash
# Registrar entrada
php artisan asistencia:registrar entrada

# Registrar salida
php artisan asistencia:registrar salida
```

## 🐛 Debugging

### Ver logs de WebSocket

La aplicación imprime logs detallados en la consola:

```dart
debugPrint('✅ WebSocket Pusher conectado exitosamente');
debugPrint('📡 Suscrito al canal Pusher: asistencias');
debugPrint('📨 Evento Pusher recibido: .NuevaAsistenciaRegistrada');
debugPrint('📝 Nueva asistencia - ID: 123, Aprendiz: Juan Pérez...');
```

### Verificar conexión WebSocket

En el dashboard, busca el indicador de estado:
- 🟢 **"En vivo"** → Conectado correctamente
- 🔴 **"Desconectado"** → Revisar configuración

### Errores comunes

**1. WebSocket no conecta:**
- ✅ Verificar que Reverb esté corriendo: `php artisan reverb:start`
- ✅ Verificar IP y puerto en `websocket_constants.dart`
- ✅ Verificar firewall no bloquee el puerto 8080

**2. No recibe eventos:**
- ✅ Verificar canal correcto: `asistencias`
- ✅ Verificar evento con punto: `.NuevaAsistenciaRegistrada`
- ✅ Verificar que el backend esté disparando eventos

**3. Error al cargar asistencias:**
- ✅ Verificar URL del API en `constants.dart`
- ✅ Verificar que el endpoint `/api/asistencia/jornada` exista
- ✅ Revisar logs de Laravel: `storage/logs/laravel.log`

## 🎓 Principios Aplicados

- ✅ **SRP (Single Responsibility Principle)**: Cada clase tiene una única responsabilidad
  - `AsistenciaProvider`: Gestión de estado
  - `ApiService`: Comunicación HTTP
  - `WebSocketPusherService`: Comunicación WebSocket
  - Widgets: Solo presentación

- ✅ **KISS (Keep It Simple, Stupid)**: Código claro y directo
  - Métodos pequeños y enfocados
  - Nombres descriptivos
  - Lógica simple y fácil de seguir

- ✅ **DRY (Don't Repeat Yourself)**: Reutilización de código
  - Modelos compartidos
  - Constantes centralizadas
  - Widgets reutilizables

- ✅ **Arquitectura Modular**: Separación clara de responsabilidades
  - `/models`: Estructuras de datos
  - `/services`: Lógica de negocio
  - `/providers`: Gestión de estado
  - `/widgets`: Componentes de UI
  - `/screens`: Pantallas completas
  - `/utils`: Utilidades y constantes

## 📚 Archivos Modificados

1. ✅ `lib/utils/constants.dart` - Nuevos endpoints
2. ✅ `lib/utils/websocket_constants.dart` - Eventos con punto
3. ✅ `lib/models/asistencia_detalle_model.dart` - **NUEVO** (maneja ficha int/string)
4. ✅ `lib/models/websocket_event.dart` - Getters mejorados
5. ✅ `lib/services/api_service.dart` - Endpoint dinámico con fecha actual
6. ✅ `lib/providers/asistencia_provider.dart` - Sin filtro de jornada + fecha dinámica
7. ✅ `lib/widgets/asistencias_tiempo_real_widget.dart` - **NUEVO**
8. ✅ `lib/widgets/asistencias_del_dia_widget.dart` - **NUEVO** (todas las jornadas del día)
9. ✅ `lib/screens/dashboard_screen.dart` - Dos nuevas secciones

## 🎉 Resultado Final

La aplicación ahora:

1. ✅ **Conecta correctamente con el backend Laravel**
2. ✅ **Carga asistencias desde el endpoint correcto**
3. ✅ **Usa fecha actual automáticamente (no hardcodeada)**
4. ✅ **Obtiene TODAS las jornadas dinámicamente (no solo una)**
5. ✅ **Recibe eventos WebSocket en tiempo real**
6. ✅ **Muestra las últimas 10 asistencias en tiempo real**
7. ✅ **Muestra TODAS las asistencias del día organizadas por jornada**
8. ✅ **Maneja correctamente tipos de datos (ficha int/string)**
9. ✅ **Soporta estados: "en_curso", "completa", "pendiente"**
10. ✅ **Actualiza estadísticas automáticamente**
11. ✅ **Indica estado de conexión WebSocket**
12. ✅ **Diferencia visualmente entradas y salidas**
13. ✅ **Mantiene arquitectura limpia y modular**

## 📋 Widgets en el Dashboard

1. **Dashboard Header** - Fecha, hora, jornada actual
2. **WebSocket Status** - Indicador de conexión
3. **Summary Cards** - Fichas, presentes, ausentes, porcentaje
4. **Charts** - Gráfico de pastel y barras
5. **Actividad Reciente** 🆕 - Últimas 10 asistencias en tiempo real
6. **Asistencias del Día** 🆕 - Todas las asistencias organizadas por jornada
7. **Fichas de Caracterización** - Lista de fichas activas

---

**Nota:** Asegúrate de que el backend Laravel esté corriendo y que Reverb esté iniciado antes de ejecutar la aplicación Flutter.

Para más información sobre el backend, consulta el archivo `README` en la raíz del proyecto.

