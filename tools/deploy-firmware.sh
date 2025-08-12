#!/bin/bash

# Script para subir nuevo firmware
VERSION=$1
FIRMWARE_FILE=$2

if [ -z "$VERSION" ] || [ -z "$FIRMWARE_FILE" ]; then
    echo "Uso: ./deploy-firmware.sh <version> <archivo_firmware>"
    echo "Ejemplo: ./deploy-firmware.sh 1.0.0 ugat_v1.0.0.bin"
    exit 1
fi

echo "🚀 Desplegando firmware v$VERSION..."

# Crear directorio de versión
mkdir -p "releases/v$VERSION"

# Copiar firmware
cp "$FIRMWARE_FILE" "releases/v$VERSION/"

# Generar MD5
MD5_HASH=$(md5sum "releases/v$VERSION/$(basename $FIRMWARE_FILE)" | cut -d' ' -f1)
echo "$MD5_HASH" > "releases/v$VERSION/checksum.md5"

# Crear changelog
cat > "releases/v$VERSION/CHANGELOG.md" << CHANGELOG_EOF
# Changelog v$VERSION

## Cambios
- Versión inicial del firmware UGAT
- Soporte para ESP32 + SIM7600
- Sistema OTA implementado

## Información Técnica
- **MD5**: $MD5_HASH
- **Archivo**: $(basename $FIRMWARE_FILE)
- **Tamaño**: $(wc -c < "$FIRMWARE_FILE") bytes
- **Fecha**: $(date +%Y-%m-%d)
CHANGELOG_EOF

echo "✅ Firmware preparado en releases/v$VERSION/"
echo "📋 MD5: $MD5_HASH"
echo ""
echo "🎯 Próximos pasos:"
echo "1. git add ."
echo "2. git commit -m 'Add firmware v$VERSION'"
echo "3. git push"
echo "4. Crear release en GitHub con el archivo: releases/v$VERSION/$(basename $FIRMWARE_FILE)"

