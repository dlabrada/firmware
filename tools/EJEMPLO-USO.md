# 🚀 Ejemplo de Uso Completo - Deploy con Push Automático

## Script para ejecutar (NO ejecutar, solo ejemplo):

```bash
# 1. Preparar nuevo firmware
cp /ruta/al/nuevo/ugat_v1.3.0.bin tools/

# 2. Cambiar al directorio tools
cd tools/

# 3. Crear release con push automático
./deploy-firmware.sh 1.3.0 ugat_v1.3.0.bin yes
```

## Output esperado:

```
ℹ️  🚀 Iniciando despliegue de firmware v1.3.0...
✅ Directorio de release creado: ../releases/v1.3.0
✅ Firmware copiado a ../releases/v1.3.0
✅ Checksum MD5 generado: [hash_md5]
✅ Changelog creado en ../releases/v1.3.0/CHANGELOG.md
✅ Archivos añadidos al stage de git
✅ Commit realizado con éxito
ℹ️  Realizando push automático...
✅ Push realizado con éxito al repositorio remoto

🎯 Release v1.3.0 completado:
   📁 Directorio: releases/v1.3.0/
   📄 Archivo: ugat_v1.3.0.bin
   🔐 MD5: [hash_md5]
   📊 Tamaño: [tamaño] bytes

ℹ️  El release está disponible en el repositorio
```

## Verificación post-deploy:

```bash
# Listar todos los releases
./list-releases.sh list

# Verificar el nuevo release
./list-releases.sh verify 1.3.0

# Ver el último release
./list-releases.sh latest
```

---

_Este archivo es solo para documentación y ejemplos_
