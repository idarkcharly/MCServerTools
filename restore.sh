#!/bin/bash

# Directorio donde se almacenan los backups
BACKUP_DIR="/home/carlos/dataswap/world_backup"

# Obtener lista de backups excluyendo "logs"
BACKUPS=($(find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d ! -name "logs" -printf "%T@ %p\n" | sort -nr | cut -d' ' -f2-))

# Verificar si hay backups disponibles
if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "No se encontraron backups disponibles."
    exit 1
fi

# Mostrar el backup más reciente antes del menú de selección
LATEST_BACKUP=$(basename "${BACKUPS[0]}")
echo "El backup más reciente es: $LATEST_BACKUP"

# Si solo hay un backup, restaurarlo automáticamente
if [ ${#BACKUPS[@]} -eq 1 ]; then
    echo "Restaurando automáticamente desde: $LATEST_BACKUP"
    rsync -a --progress "${BACKUPS[0]}/" "/ruta/del/servidor/minecraft/world/"
    echo "Restauración completada."
    exit 0
fi

# Mostrar backups con el más reciente como opción 1
echo "Selecciona un backup para restaurar:"
select backup in "${BACKUPS[@]}"; do
    if [[ -n "$backup" ]]; then
        echo "Restaurando desde: $(basename "$backup")"
        rsync -a --progress "$backup/" "/ruta/del/servidor/minecraft/world/"
        echo "Restauración completada."
        break
    else
        echo "Selección inválida. Intenta de nuevo."
    fi
done
