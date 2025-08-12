# 🚀 UGAT Firmware Repository

Repositorio público para firmware del sistema UGAT con soporte OTA (Over-The-Air) updates.

## 📦 Releases Disponibles

### v1.0.0 (Latest)
- **Archivo**: [ugat_v1.0.0.bin](releases/download/v1.0.0/ugat_v1.0.0.bin)
- **Tamaño**: TBD
- **MD5**: TBD
- **Fecha**: 2025-08-12

## 🔄 Actualización OTA

Para actualizar el firmware vía MQTT:

```json
{
  "command": "downloadFirmware",
  "requestId": "fw_001",
  "data": {
    "firmwareUrl": "https://github.com/dlabrada/firmware/releases/download/v1.0.0/ugat_v1.0.0.bin",
    "version": "1.0.0",
    "checksum": "MD5_CHECKSUM_AQUI",
    "authorize": "YOUR_PASSWORD"
  }
}
```

## 📱 Dispositivos Compatibles

- ESP32 con SIM7600
- Módulo UGAT v2.x

## 🔒 Seguridad

- Todos los firmware incluyen validación MD5
- Autenticación requerida para comandos OTA
- Rollback automático en caso de fallos

