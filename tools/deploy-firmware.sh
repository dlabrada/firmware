#!/bin/bash

# Script automatizado para desplegar firmware UGAT
# Autor: dlabrada
# Fecha: $(date +%Y-%m-%d)

set -e  # Salir si hay errores

VERSION=$1
FIRMWARE_FILE=$2
AUTO_PUSH=${3:-"no"}  # Tercer parámetro opcional para auto-push
MOVE_FILE=${4:-"move"}  # Cuarto parámetro: "move", "delete", "keep"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes con colores
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar parámetros
if [ -z "$VERSION" ]; then
    log_error "Falta el parámetro VERSION"
    echo "Uso: ./deploy-firmware.sh <version> [archivo_firmware] [auto_push] [accion_archivo]"
    echo "Ejemplos:"
    echo "  ./deploy-firmware.sh 1.2.0"
    echo "  ./deploy-firmware.sh 1.2.0 ugat_v1.2.0.bin"
    echo "  ./deploy-firmware.sh 1.2.0 ugat_v1.2.0.bin yes"
    echo "  ./deploy-firmware.sh 1.2.0 ugat_v1.2.0.bin yes move"
    echo "  ./deploy-firmware.sh 1.2.0 ugat_v1.2.0.bin no delete"
    echo ""
    echo "Parámetros:"
    echo "  version         - Versión del release (ej: 1.2.0)"
    echo "  archivo_firmware - Archivo .bin (opcional, se detecta automáticamente)"
    echo "  auto_push       - 'yes' para push automático (opcional, default: no)"
    echo "  accion_archivo  - 'move'|'delete'|'keep' (opcional, default: move)"
    echo "    move   - Mueve el archivo a carpeta archive/"
    echo "    delete - Elimina el archivo original"
    echo "    keep   - Mantiene el archivo original"
    exit 1
fi

# Si no se especifica archivo, buscar automáticamente
if [ -z "$FIRMWARE_FILE" ]; then
    # Buscar archivo .bin en el directorio tools
    FIRMWARE_FILES=(*.bin)
    if [ ${#FIRMWARE_FILES[@]} -eq 1 ] && [ -f "${FIRMWARE_FILES[0]}" ]; then
        FIRMWARE_FILE="${FIRMWARE_FILES[0]}"
        log_info "Archivo detectado automáticamente: $FIRMWARE_FILE"
    elif [ ${#FIRMWARE_FILES[@]} -gt 1 ]; then
        log_warning "Múltiples archivos .bin encontrados:"
        for file in "${FIRMWARE_FILES[@]}"; do
            echo "  - $file"
        done
        log_error "Por favor especifica el archivo de firmware"
        exit 1
    else
        log_error "No se encontró ningún archivo .bin en el directorio tools"
        exit 1
    fi
fi

# Verificar que el archivo existe
if [ ! -f "$FIRMWARE_FILE" ]; then
    log_error "El archivo $FIRMWARE_FILE no existe"
    exit 1
fi

# Verificar que estamos en el directorio correcto
if [ ! -d "../releases" ]; then
    log_error "No se encontró el directorio releases. Asegúrate de ejecutar desde el directorio tools"
    exit 1
fi

log_info "🚀 Iniciando despliegue de firmware v$VERSION..."

# Crear directorio de versión
RELEASE_DIR="../releases/v$VERSION"
mkdir -p "$RELEASE_DIR"
log_success "Directorio de release creado: $RELEASE_DIR"

# Copiar firmware al directorio de release
cp "$FIRMWARE_FILE" "$RELEASE_DIR/"
log_success "Firmware copiado a $RELEASE_DIR"

# Gestionar archivo original según la configuración
case "$MOVE_FILE" in
    "move")
        # Crear directorio archive si no existe
        mkdir -p "archive"
        mv "$FIRMWARE_FILE" "archive/"
        log_success "Archivo original movido a archive/$(basename $FIRMWARE_FILE)"
        ;;
    "delete")
        rm "$FIRMWARE_FILE"
        log_success "Archivo original eliminado: $FIRMWARE_FILE"
        ;;
    "keep")
        log_info "Archivo original mantenido: $FIRMWARE_FILE"
        ;;
    *)
        log_warning "Acción desconocida '$MOVE_FILE', manteniendo archivo original"
        ;;
esac

# Generar MD5 (compatible con macOS y Linux)
if command -v md5sum > /dev/null; then
    MD5_HASH=$(md5sum "$RELEASE_DIR/$(basename $FIRMWARE_FILE)" | cut -d' ' -f1)
elif command -v md5 > /dev/null; then
    MD5_HASH=$(md5 -q "$RELEASE_DIR/$(basename $FIRMWARE_FILE)")
else
    log_error "No se encontró comando md5sum o md5"
    exit 1
fi

echo "$MD5_HASH" > "$RELEASE_DIR/checksum.md5"
log_success "Checksum MD5 generado: $MD5_HASH"

# Obtener información del archivo
FILE_SIZE=$(wc -c < "$RELEASE_DIR/$(basename $FIRMWARE_FILE)" | tr -d ' ')
CURRENT_DATE=$(date +%Y-%m-%d)
CURRENT_TIME=$(date +%H:%M:%S)

# Crear changelog
cat > "$RELEASE_DIR/CHANGELOG.md" << CHANGELOG_EOF
# Changelog v$VERSION

## 📦 Información del Release
- **Versión**: $VERSION
- **Fecha**: $CURRENT_DATE $CURRENT_TIME
- **Archivo**: $(basename $FIRMWARE_FILE)
- **Tamaño**: $FILE_SIZE bytes
- **MD5**: $MD5_HASH

## 🔧 Cambios Técnicos
- Firmware UGAT actualizado
- Compatibilidad con ESP32 + SIM7600
- Sistema OTA integrado

## 📋 Instrucciones de Instalación
1. Descargar el archivo $(basename $FIRMWARE_FILE)
2. Verificar integridad con MD5: $MD5_HASH
3. Flashear usando herramientas ESP32

---
*Release generado automáticamente por deploy-firmware.sh*
CHANGELOG_EOF

log_success "Changelog creado en $RELEASE_DIR/CHANGELOG.md"

# Cambiar al directorio raíz del proyecto para git
cd ..

# Verificar estado de git
if [ ! -d ".git" ]; then
    log_error "No es un repositorio git"
    exit 1
fi

# Añadir archivos al stage
git add releases/v$VERSION/
log_success "Archivos añadidos al stage de git"

# Hacer commit
COMMIT_MSG="🚀 Add firmware release v$VERSION

- Firmware: $(basename $FIRMWARE_FILE)
- MD5: $MD5_HASH
- Size: $FILE_SIZE bytes
- Date: $CURRENT_DATE"

git commit -m "$COMMIT_MSG"
log_success "Commit realizado con éxito"

# Auto-push si se solicita
if [ "$AUTO_PUSH" = "yes" ] || [ "$AUTO_PUSH" = "y" ]; then
    log_info "Realizando push automático..."
    
    # Verificar conexión remota
    if git remote get-url origin > /dev/null 2>&1; then
        git push origin main
        log_success "Push realizado con éxito al repositorio remoto"
        
        # Información del release
        echo ""
        echo "🎯 Release v$VERSION completado:"
        echo "   📁 Directorio: releases/v$VERSION/"
        echo "   📄 Archivo: $(basename $FIRMWARE_FILE)"
        echo "   🔐 MD5: $MD5_HASH"
        echo "   📊 Tamaño: $FILE_SIZE bytes"
        
        # Mostrar información sobre el archivo original
        case "$MOVE_FILE" in
            "move")
                echo "   📦 Archivo original: Movido a archive/"
                ;;
            "delete")
                echo "   🗑️  Archivo original: Eliminado"
                ;;
            "keep")
                echo "   💾 Archivo original: Mantenido en tools/"
                ;;
        esac
        
        echo ""
        log_info "El release está disponible en el repositorio"
        
    else
        log_warning "No se pudo conectar al repositorio remoto"
        log_info "Ejecuta manualmente: git push origin main"
    fi
else
    echo ""
    echo "🎯 Release v$VERSION preparado localmente:"
    echo "   📁 Directorio: releases/v$VERSION/"
    echo "   📄 Archivo: $(basename $FIRMWARE_FILE)"
    echo "   🔐 MD5: $MD5_HASH"
    echo "   📊 Tamaño: $FILE_SIZE bytes"
    
    # Mostrar información sobre el archivo original
    case "$MOVE_FILE" in
        "move")
            echo "   📦 Archivo original: Movido a archive/"
            ;;
        "delete")
            echo "   🗑️  Archivo original: Eliminado"
            ;;
        "keep")
            echo "   💾 Archivo original: Mantenido en tools/"
            ;;
    esac
    
    echo ""
    log_info "Para subir al repositorio ejecuta:"
    echo "   git push origin main"
    echo ""
    log_info "O ejecuta el script con 'yes' para auto-push:"
    echo "   ./deploy-firmware.sh $VERSION $(basename $FIRMWARE_FILE) yes $MOVE_FILE"
fi