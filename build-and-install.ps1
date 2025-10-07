# Script de compilación e instalación de APK
# Dashboard de Asistencia SENA

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  DASHBOARD ASISTENCIA - BUILD APK  " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Limpiar proyecto
Write-Host "[1/4] Limpiando proyecto..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error en flutter clean" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Proyecto limpio" -ForegroundColor Green
Write-Host ""

# Paso 2: Obtener dependencias
Write-Host "[2/4] Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error en flutter pub get" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Dependencias obtenidas" -ForegroundColor Green
Write-Host ""

# Paso 3: Compilar APK
Write-Host "[3/4] Compilando APK Release..." -ForegroundColor Yellow
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error en flutter build apk" -ForegroundColor Red
    exit 1
}
Write-Host "✓ APK compilado exitosamente" -ForegroundColor Green
Write-Host ""

# Verificar que el APK existe
$apkPath = "android\app\build\outputs\apk\release\app-release.apk"
if (Test-Path $apkPath) {
    $apkSize = (Get-Item $apkPath).Length / 1MB
    Write-Host "✓ APK generado: $apkPath" -ForegroundColor Green
    Write-Host "  Tamaño: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "✗ No se encontró el APK en la ruta esperada" -ForegroundColor Red
    exit 1
}

# Paso 4: Preguntar si desea instalar
Write-Host "[4/4] ¿Desea instalar el APK en un dispositivo conectado? (S/N)" -ForegroundColor Yellow
$respuesta = Read-Host

if ($respuesta -eq 'S' -or $respuesta -eq 's') {
    Write-Host "Verificando dispositivos conectados..." -ForegroundColor Cyan
    adb devices
    Write-Host ""
    Write-Host "Instalando APK..." -ForegroundColor Yellow
    adb install -r $apkPath
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ APK instalado correctamente" -ForegroundColor Green
    } else {
        Write-Host "✗ Error al instalar el APK" -ForegroundColor Red
        Write-Host "  Asegúrate de que ADB esté configurado y el dispositivo conectado" -ForegroundColor Yellow
    }
} else {
    Write-Host "APK generado pero no instalado" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  PROCESO COMPLETADO  " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ubicación del APK:" -ForegroundColor White
Write-Host "  $apkPath" -ForegroundColor Cyan
Write-Host ""

