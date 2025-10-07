#!/bin/bash
# Script de compilación e instalación de APK
# Dashboard de Asistencia SENA

# Colores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}  DASHBOARD ASISTENCIA - BUILD APK  ${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""

# Paso 1: Limpiar proyecto
echo -e "${YELLOW}[1/4] Limpiando proyecto...${NC}"
flutter clean
if [ $? -ne 0 ]; then
    echo -e "${RED}Error en flutter clean${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Proyecto limpio${NC}"
echo ""

# Paso 2: Obtener dependencias
echo -e "${YELLOW}[2/4] Obteniendo dependencias...${NC}"
flutter pub get
if [ $? -ne 0 ]; then
    echo -e "${RED}Error en flutter pub get${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Dependencias obtenidas${NC}"
echo ""

# Paso 3: Compilar APK
echo -e "${YELLOW}[3/4] Compilando APK Release...${NC}"
flutter build apk --release
if [ $? -ne 0 ]; then
    echo -e "${RED}Error en flutter build apk${NC}"
    exit 1
fi
echo -e "${GREEN}✓ APK compilado exitosamente${NC}"
echo ""

# Verificar que el APK existe
APK_PATH="android/app/build/outputs/apk/release/app-release.apk"
if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo -e "${GREEN}✓ APK generado: $APK_PATH${NC}"
    echo -e "${CYAN}  Tamaño: $APK_SIZE${NC}"
    echo ""
else
    echo -e "${RED}✗ No se encontró el APK en la ruta esperada${NC}"
    exit 1
fi

# Paso 4: Preguntar si desea instalar
echo -e "${YELLOW}[4/4] ¿Desea instalar el APK en un dispositivo conectado? (s/n)${NC}"
read -r respuesta

if [ "$respuesta" = "s" ] || [ "$respuesta" = "S" ]; then
    echo -e "${CYAN}Verificando dispositivos conectados...${NC}"
    adb devices
    echo ""
    echo -e "${YELLOW}Instalando APK...${NC}"
    adb install -r "$APK_PATH"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ APK instalado correctamente${NC}"
    else
        echo -e "${RED}✗ Error al instalar el APK${NC}"
        echo -e "${YELLOW}  Asegúrate de que ADB esté configurado y el dispositivo conectado${NC}"
    fi
else
    echo -e "${CYAN}APK generado pero no instalado${NC}"
fi

echo ""
echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}  PROCESO COMPLETADO  ${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""
echo -e "Ubicación del APK:"
echo -e "${CYAN}  $APK_PATH${NC}"
echo ""

