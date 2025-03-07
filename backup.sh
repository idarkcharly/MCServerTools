#!/bin/bash

MINECRAFT_SERVER_DIR="/home/carlos/server"
WORLD_DIR="$MINECRAFT_SERVER_DIR/world"
BACKUP_DIR="/home/carlos/dataswap/world_backup"
LOG_DIR="$BACKUP_DIR/logs"
LOG_FILE="$LOG_DIR/backup.log"
VERSION="1.17.1"

# Crear directorio de logs si no existe
mkdir -p "$LOG_DIR"

# Registrar la versión al inicio del archivo de log
if [ ! -f "$LOG_FILE" ]; then
    echo "Version:$VERSION" >>"$LOG_FILE"
fi

backup() {
    while true; do
        read -p "Desea crear una copia de seguridad? (y/n): " confirm
        case $confirm in
        [Yy]*) break ;;
        [Nn]*)
            timestamp=$(date "+%d_%m_%Y_%I_%M_%p")
            read -p "Motivo de no guardar: " reason
            echo "$timestamp [Ignorado] [$reason]" >>"$LOG_FILE"
            echo "Copia de seguridad cancelada."
            return 0
            ;;
        *) echo "Por favor, ingrese 'y' o 'n'." ;;
        esac
    done

    timestamp=$(date "+%d-%m-%Y %I:%M:%S %p")

    # Realizar la copia de seguridad
    read -p "Trabajo realizado: " work_done
    backup_name="$(LC_TIME=en_US.UTF-8 date '+%d_%m_%Y_%I_%M_%S_%p')"

    # Verificar si ya existe el directorio
    if [ -d "$BACKUP_DIR/$backup_name" ]; then
        echo "Error: La carpeta de backup '$backup_name' ya existe. Cambiando nombre..."
        backup_name="${backup_name}_$(date '+%S')"  # Agregar segundos para evitar colisión
    fi

    mkdir -p "$BACKUP_DIR/$backup_name"
    
    rsync -a --progress "$WORLD_DIR/" "$BACKUP_DIR/$backup_name/"

    echo "Copia de seguridad creada con éxito en: $BACKUP_DIR/$backup_name"
    echo "$timestamp [Guardado] [$work_done]" >>"$LOG_FILE"

    # Eliminar copias de seguridad antiguas (más de 7 días)
    find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} +
    echo "Copias de seguridad antiguas eliminadas."
}

# Ejecutar backup directamente
backup
