# Configuración del Servidor Pusher/Laravel Reverb

## Problema Actual
El error `{"code":4001,"message":"Application does not exist"}` indica que la aplicación Pusher con key `local` no existe en el servidor WebSocket.

## Solución Requerida en el Backend

### 1. Configurar Laravel Reverb
En el archivo `.env` del backend Laravel, agregar:

```env
# Laravel Reverb Configuration
REVERB_APP_ID=local
REVERB_APP_KEY=local
REVERB_APP_SECRET=your-secret-key-here
REVERB_HOST="10.7.55.97"
REVERB_PORT=8080
REVERB_SCHEME=http

# Pusher Configuration (para compatibilidad)
PUSHER_APP_ID=local
PUSHER_APP_KEY=local
PUSHER_APP_SECRET=your-secret-key-here
PUSHER_HOST="10.7.55.97"
PUSHER_PORT=8080
PUSHER_SCHEME=http
PUSHER_APP_CLUSTER=mt1
```

### 2. Iniciar el Servidor Reverb
```bash
php artisan reverb:start
```

### 3. Configurar Broadcasting
En `config/broadcasting.php`, asegurar que la configuración de Reverb esté correcta:

```php
'reverb' => [
    'driver' => 'reverb',
    'key' => env('REVERB_APP_KEY'),
    'secret' => env('REVERB_APP_SECRET'),
    'app_id' => env('REVERB_APP_ID'),
    'options' => [
        'host' => env('REVERB_HOST', '127.0.0.1'),
        'port' => env('REVERB_PORT', 443),
        'scheme' => env('REVERB_SCHEME', 'https'),
        'useTLS' => env('REVERB_SCHEME', 'https') === 'https',
    ],
],
```

### 4. Configurar Canales
En el archivo de rutas de broadcasting (`routes/channels.php`):

```php
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('asistencias', function () {
    return true; // Canal público para asistencias
});

Broadcast::channel('qr-scans', function () {
    return true; // Canal público para QR scans
});
```

### 5. Eventos de Broadcasting
Crear eventos para broadcasting:

```php
// app/Events/NuevaAsistenciaRegistrada.php
class NuevaAsistenciaRegistrada implements ShouldBroadcast
{
    public function broadcastOn()
    {
        return new Channel('asistencias');
    }

    public function broadcastAs()
    {
        return 'NuevaAsistenciaRegistrada';
    }
}
```

## Verificación
Una vez configurado, el frontend debería conectarse exitosamente y recibir eventos en tiempo real.

## Estado Actual del Frontend
✅ **Configurado correctamente:**
- IP: `10.7.55.97:8080`
- Key: `local`
- Canales: `asistencias`, `qr-scans`
- Eventos: `NuevaAsistenciaRegistrada`, `QrScanned`
- Reconexión automática con backoff progresivo
- Polling de fallback cada 1 segundo
- Respuesta ultra-rápida (< 1 segundo)

El frontend está listo y esperando que el backend esté configurado correctamente.
