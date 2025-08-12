#!/bin/bash

# Script para gestionar archivos archivados de firmware
# Autor: dlabrada

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# Función para mostrar ayuda
show_help() {
    echo -e "${CYAN}📦 GESTIÓN DE ARCHIVOS ARCHIVADOS${NC}"
    echo "=============================================="
    echo ""
    echo -e "${CYAN}USO:${NC}"
    echo "  ./manage-archive.sh [comando] [parámetros]"
    echo ""
    echo -e "${CYAN}COMANDOS:${NC}"
    echo "  list                     - Listar archivos archivados"
    echo "  restore <archivo>        - Restaurar archivo desde archive/"
    echo "  clean                    - Limpiar archivos archivados antiguos"
    echo "  info <archivo>           - Mostrar información de un archivo"
    echo "  help                     - Mostrar esta ayuda"
    echo ""
    echo -e "${CYAN}EJEMPLOS:${NC}"
    echo "  ./manage-archive.sh list"
    echo "  ./manage-archive.sh restore ugat_v1.1.0.bin"
    echo "  ./manage-archive.sh info ugat_v1.0.0.bin"
    echo "  ./manage-archive.sh clean"
}

# Función para listar archivos archivados
list_archived() {
    echo -e "${CYAN}📦 ARCHIVOS ARCHIVADOS${NC}"
    echo "=============================================="
    
    if [ ! -d "archive" ]; then
        log_warning "Directorio archive/ no existe"
        return
    fi
    
    local archived_files=(archive/*.bin)
    
    if [ ${#archived_files[@]} -eq 1 ] && [ ! -f "${archived_files[0]}" ]; then
        log_info "No hay archivos archivados"
        return
    fi
    
    echo -e "${CYAN}Total de archivos: ${#archived_files[@]}${NC}"
    echo ""
    
    for file in "${archived_files[@]}"; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            local file_size=$(wc -c < "$file" | tr -d ' ')
            local mod_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d'.' -f1)
            
            echo "📄 $filename"
            echo "   📊 Tamaño: $file_size bytes"
            echo "   📅 Archivado: $mod_date"
            echo ""
        fi
    done
}

# Función para restaurar archivo
restore_file() {
    local filename=$1
    
    if [ -z "$filename" ]; then
        log_error "Especifica el archivo a restaurar"
        echo "Uso: ./manage-archive.sh restore <archivo>"
        return 1
    fi
    
    local archive_path="archive/$filename"
    
    if [ ! -f "$archive_path" ]; then
        log_error "Archivo $filename no encontrado en archive/"
        return 1
    fi
    
    if [ -f "$filename" ]; then
        log_warning "El archivo $filename ya existe en tools/"
        read -p "¿Sobrescribir? (y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            log_info "Operación cancelada"
            return 0
        fi
    fi
    
    cp "$archive_path" "./"
    log_success "Archivo $filename restaurado desde archive/"
}

# Función para mostrar información de archivo
show_file_info() {
    local filename=$1
    
    if [ -z "$filename" ]; then
        log_error "Especifica el archivo"
        echo "Uso: ./manage-archive.sh info <archivo>"
        return 1
    fi
    
    local archive_path="archive/$filename"
    
    if [ ! -f "$archive_path" ]; then
        log_error "Archivo $filename no encontrado en archive/"
        return 1
    fi
    
    echo -e "${CYAN}📄 INFORMACIÓN DEL ARCHIVO${NC}"
    echo "=============================================="
    echo "📄 Nombre: $filename"
    echo "📁 Ubicación: $archive_path"
    
    local file_size=$(wc -c < "$archive_path" | tr -d ' ')
    echo "📊 Tamaño: $file_size bytes"
    
    local mod_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$archive_path" 2>/dev/null || stat -c "%y" "$archive_path" 2>/dev/null | cut -d'.' -f1)
    echo "📅 Archivado: $mod_date"
    
    # Calcular MD5
    local md5_hash
    if command -v md5sum > /dev/null; then
        md5_hash=$(md5sum "$archive_path" | cut -d' ' -f1)
    elif command -v md5 > /dev/null; then
        md5_hash=$(md5 -q "$archive_path")
    else
        md5_hash="No disponible"
    fi
    echo "🔐 MD5: $md5_hash"
}

# Función para limpiar archivos antiguos
clean_archive() {
    echo -e "${CYAN}🧹 LIMPIAR ARCHIVOS ARCHIVADOS${NC}"
    echo "=============================================="
    
    if [ ! -d "archive" ]; then
        log_warning "Directorio archive/ no existe"
        return
    fi
    
    local archived_files=(archive/*.bin)
    
    if [ ${#archived_files[@]} -eq 1 ] && [ ! -f "${archived_files[0]}" ]; then
        log_info "No hay archivos para limpiar"
        return
    fi
    
    echo "Se encontraron ${#archived_files[@]} archivo(s) archivado(s):"
    for file in "${archived_files[@]}"; do
        if [ -f "$file" ]; then
            echo "  - $(basename "$file")"
        fi
    done
    
    echo ""
    log_warning "Esta acción eliminará PERMANENTEMENTE todos los archivos archivados"
    read -p "¿Continuar? (y/N): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        rm -f archive/*.bin
        log_success "Archivos archivados eliminados"
    else
        log_info "Operación cancelada"
    fi
}

# Verificar que estamos en el directorio correcto
if [ ! -f "deploy-firmware.sh" ]; then
    log_error "Ejecuta desde el directorio tools/"
    exit 1
fi

# Procesar argumentos
case "${1:-list}" in
    "list")
        list_archived
        ;;
    "restore")
        restore_file "$2"
        ;;
    "info")
        show_file_info "$2"
        ;;
    "clean")
        clean_archive
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        log_error "Comando desconocido: $1"
        show_help
        exit 1
        ;;
esac
