#!/bin/bash

# Script para listar y gestionar releases de firmware UGAT
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

# Verificar que estamos en el directorio correcto
if [ ! -d "../releases" ]; then
    log_error "No se encontró el directorio releases. Ejecuta desde el directorio tools"
    exit 1
fi

echo -e "${CYAN}📦 GESTIÓN DE RELEASES FIRMWARE UGAT${NC}"
echo "=============================================="

# Función para mostrar información de un release
show_release_info() {
    local version_dir=$1
    local version=$(basename "$version_dir")
    
    echo -e "\n${GREEN}📋 Release $version${NC}"
    echo "----------------------------------------"
    
    # Buscar archivo de firmware
    local firmware_file=$(find "$version_dir" -name "*.bin" -type f | head -1)
    if [ -n "$firmware_file" ]; then
        local filename=$(basename "$firmware_file")
        local file_size=$(wc -c < "$firmware_file" | tr -d ' ')
        echo "📄 Archivo: $filename"
        echo "📊 Tamaño: $file_size bytes"
    else
        echo "📄 Archivo: No encontrado"
    fi
    
    # Mostrar MD5 si existe
    if [ -f "$version_dir/checksum.md5" ]; then
        local md5_hash=$(cat "$version_dir/checksum.md5")
        echo "🔐 MD5: $md5_hash"
    else
        echo "🔐 MD5: No disponible"
    fi
    
    # Mostrar fecha de modificación
    local mod_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$version_dir" 2>/dev/null || stat -c "%y" "$version_dir" 2>/dev/null | cut -d'.' -f1)
    echo "📅 Fecha: $mod_date"
    
    # Verificar si hay changelog
    if [ -f "$version_dir/CHANGELOG.md" ]; then
        echo "📝 Changelog: Disponible"
    else
        echo "📝 Changelog: No disponible"
    fi
}

# Función para listar todos los releases
list_all_releases() {
    local releases_dir="../releases"
    local version_dirs=($(find "$releases_dir" -name "v*" -type d | sort -V))
    
    if [ ${#version_dirs[@]} -eq 0 ]; then
        log_warning "No se encontraron releases"
        return
    fi
    
    echo -e "${CYAN}Total de releases encontrados: ${#version_dirs[@]}${NC}"
    
    for version_dir in "${version_dirs[@]}"; do
        show_release_info "$version_dir"
    done
}

# Función para mostrar release específico
show_specific_release() {
    local version=$1
    local version_dir="../releases/v$version"
    
    if [ ! -d "$version_dir" ]; then
        log_error "Release v$version no encontrado"
        return 1
    fi
    
    show_release_info "$version_dir"
    
    # Mostrar changelog si existe
    if [ -f "$version_dir/CHANGELOG.md" ]; then
        echo -e "\n${CYAN}📝 CHANGELOG:${NC}"
        echo "----------------------------------------"
        cat "$version_dir/CHANGELOG.md"
    fi
}

# Función para verificar integridad
verify_release() {
    local version=$1
    local version_dir="../releases/v$version"
    
    if [ ! -d "$version_dir" ]; then
        log_error "Release v$version no encontrado"
        return 1
    fi
    
    log_info "Verificando integridad del release v$version..."
    
    # Buscar archivo de firmware
    local firmware_file=$(find "$version_dir" -name "*.bin" -type f | head -1)
    if [ -z "$firmware_file" ]; then
        log_error "No se encontró archivo de firmware"
        return 1
    fi
    
    # Verificar MD5 si existe
    if [ -f "$version_dir/checksum.md5" ]; then
        local stored_md5=$(cat "$version_dir/checksum.md5")
        
        # Calcular MD5 actual
        local current_md5
        if command -v md5sum > /dev/null; then
            current_md5=$(md5sum "$firmware_file" | cut -d' ' -f1)
        elif command -v md5 > /dev/null; then
            current_md5=$(md5 -q "$firmware_file")
        else
            log_error "No se encontró comando md5sum o md5"
            return 1
        fi
        
        if [ "$stored_md5" = "$current_md5" ]; then
            log_success "Integridad verificada correctamente"
            echo "MD5: $current_md5"
        else
            log_error "Fallo en verificación de integridad"
            echo "MD5 almacenado: $stored_md5"
            echo "MD5 actual: $current_md5"
            return 1
        fi
    else
        log_warning "No hay checksum MD5 para verificar"
    fi
}

# Función para mostrar ayuda
show_help() {
    echo -e "${CYAN}USO:${NC}"
    echo "  ./list-releases.sh [comando] [parámetros]"
    echo ""
    echo -e "${CYAN}COMANDOS:${NC}"
    echo "  list                     - Listar todos los releases"
    echo "  show <version>          - Mostrar información de un release específico"
    echo "  verify <version>        - Verificar integridad de un release"
    echo "  latest                  - Mostrar el release más reciente"
    echo "  help                    - Mostrar esta ayuda"
    echo ""
    echo -e "${CYAN}EJEMPLOS:${NC}"
    echo "  ./list-releases.sh list"
    echo "  ./list-releases.sh show 1.0.0"
    echo "  ./list-releases.sh verify 1.1.0"
    echo "  ./list-releases.sh latest"
}

# Función para mostrar el último release
show_latest() {
    local releases_dir="../releases"
    local latest_dir=$(find "$releases_dir" -name "v*" -type d | sort -V | tail -1)
    
    if [ -z "$latest_dir" ]; then
        log_warning "No se encontraron releases"
        return
    fi
    
    local latest_version=$(basename "$latest_dir")
    echo -e "${CYAN}🏆 ÚLTIMO RELEASE: $latest_version${NC}"
    show_release_info "$latest_dir"
}

# Procesar argumentos
case "${1:-list}" in
    "list")
        list_all_releases
        ;;
    "show")
        if [ -z "$2" ]; then
            log_error "Especifica la versión a mostrar"
            echo "Uso: ./list-releases.sh show <version>"
            exit 1
        fi
        show_specific_release "$2"
        ;;
    "verify")
        if [ -z "$2" ]; then
            log_error "Especifica la versión a verificar"
            echo "Uso: ./list-releases.sh verify <version>"
            exit 1
        fi
        verify_release "$2"
        ;;
    "latest")
        show_latest
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
