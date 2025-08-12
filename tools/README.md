# 🔧 Herramientas de Gestión de Firmware UGAT

Este directorio contiene las herramientas para gestionar releases de firmware del proyecto UGAT.

## 📄 Archivos

- `deploy-firmware.sh` - Script principal para crear y desplegar releases
- `list-releases.sh` - Script para listar y gestionar releases existentes
- `ugat_v1.1.0.bin` - Archivo de firmware actual

## 🚀 deploy-firmware.sh

Script automatizado para crear releases de firmware que incluye:

- ✅ Detección automática de archivos .bin
- ✅ Generación de checksum MD5
- ✅ Creación de changelog automático
- ✅ Commit y push automático al repositorio
- ✅ Compatibilidad con macOS y Linux

### Uso

```bash
# Uso básico (detecta automáticamente el archivo .bin)
./deploy-firmware.sh <version>

# Especificar archivo de firmware
./deploy-firmware.sh <version> <archivo_firmware>

# Con push automático al repositorio
./deploy-firmware.sh <version> <archivo_firmware> yes
```

### Ejemplos

```bash
# Detectar automáticamente y crear release
./deploy-firmware.sh 1.2.0

# Especificar archivo específico
./deploy-firmware.sh 1.2.0 ugat_v1.2.0.bin

# Crear release y subir automáticamente
./deploy-firmware.sh 1.2.0 ugat_v1.2.0.bin yes
```

### Lo que hace el script

1. 📁 Crea directorio `../releases/v{VERSION}/`
2. 📋 Copia el archivo de firmware
3. 🔐 Genera checksum MD5
4. 📝 Crea changelog automático
5. 📦 Hace commit en git
6. 🚀 Push al repositorio (opcional)

## 📋 list-releases.sh

Script para gestionar y verificar releases existentes.

### Comandos disponibles

```bash
# Listar todos los releases
./list-releases.sh list

# Mostrar información de un release específico
./list-releases.sh show <version>

# Verificar integridad de un release
./list-releases.sh verify <version>

# Mostrar el release más reciente
./list-releases.sh latest

# Mostrar ayuda
./list-releases.sh help
```

### Ejemplos

```bash
# Ver todos los releases
./list-releases.sh list

# Ver detalles del release 1.0.0
./list-releases.sh show 1.0.0

# Verificar integridad del firmware
./list-releases.sh verify 1.1.0

# Ver el último release
./list-releases.sh latest
```

## 🔄 Flujo de Trabajo Recomendado

### 1. Preparar nuevo firmware

```bash
# Copiar el nuevo archivo .bin al directorio tools/
cp /ruta/al/nuevo/ugat_v1.3.0.bin tools/
```

### 2. Crear release

```bash
cd tools/
# Opción 1: Detección automática
./deploy-firmware.sh 1.3.0

# Opción 2: Con push automático
./deploy-firmware.sh 1.3.0 ugat_v1.3.0.bin yes
```

### 3. Verificar release

```bash
# Listar todos los releases
./list-releases.sh list

# Verificar integridad
./list-releases.sh verify 1.3.0
```

## 📂 Estructura de Release

Cada release genera la siguiente estructura:

```
releases/v{VERSION}/
├── ugat_v{VERSION}.bin     # Archivo de firmware
├── checksum.md5            # Hash MD5 del firmware
└── CHANGELOG.md           # Información del release
```

## 🔧 Características

### deploy-firmware.sh

- ✅ **Detección automática**: Encuentra archivos .bin automáticamente
- ✅ **Multiplataforma**: Compatible con macOS (md5) y Linux (md5sum)
- ✅ **Validación**: Verifica archivos y directorios antes de proceder
- ✅ **Git integrado**: Commit y push automático
- ✅ **Colores**: Output colorizado para mejor UX
- ✅ **Logging**: Mensajes informativos durante el proceso

### list-releases.sh

- ✅ **Vista completa**: Muestra información detallada de releases
- ✅ **Verificación**: Valida integridad usando MD5
- ✅ **Ordenamiento**: Lista releases en orden de versión
- ✅ **Búsqueda**: Encuentra releases específicos
- ✅ **Estado**: Muestra fechas y tamaños de archivos

## 🛡️ Seguridad

- Los scripts validan la existencia de archivos antes de proceder
- Verificación de integridad usando checksums MD5
- Manejo de errores y salida segura
- No sobrescribe releases existentes sin confirmación

## 📝 Notas

- Ejecutar siempre desde el directorio `tools/`
- Los releases se crean en `../releases/v{VERSION}/`
- El script es compatible con git y genera commits automáticos
- Los checksums MD5 se generan automáticamente
- El formato de versión debe ser: X.Y.Z (ej: 1.0.0, 2.1.5)

## 🆘 Solución de Problemas

### Error: "No se encontró el directorio releases"

```bash
# Asegúrate de estar en el directorio tools
cd tools/
```

### Error: "No se encontró ningún archivo .bin"

```bash
# Copia tu archivo de firmware al directorio tools
cp /ruta/al/firmware.bin tools/
```

### Error: "No se encontró comando md5sum o md5"

```bash
# En macOS debería funcionar automáticamente
# En Linux instalar: sudo apt-get install coreutils
```

---

_Herramientas creadas para el proyecto Firmware UGAT_
