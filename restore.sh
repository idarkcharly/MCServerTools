#!/bin/bash


MINECRAFT_SERVER_DIR="/home/carlos/server"
WORLD_DIR="$MINECRAFT_SERVER_DIR/world"
BACKUP_DIR="/home/carlos/dataswap/world_backup"


# Verificar si existen copias de seguridad

if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
    echo "No hay copias de seguridad disponibles en $BACKUP_DIR."
    exit 1
fi


# Listar copias de seguridad (excluyendo "logs")
echo "Copias de seguridad disponibles:"
mapfile -t BACKUPS < <(find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d ! -name "logs" -printf "%f\n")

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "No hay copias de seguridad disponibles (excepto logs)."
    exit 1
fi

select backup in "${BACKUPS[@]}"; do
    if [ -n "$backup" ]; then
        BACKUP_PATH="$BACKUP_DIR/$backup"
        echo "Restaurando desde: $BACKUP_PATH"
        break
    else
        echo "Selección no válida, intenta de nuevo."
    fi
done


# Confirmar restauración

read -p "¿Está seguro de que desea restaurar '$backup' en '$WORLD_DIR'? (y/n): " confirm
if [[ "$confirm" =~ ^[Nn]$ ]]; then
    echo "Restauración cancelada."
    exit 0
fi


# Restaurar con rsync (excluyendo "logs")

echo "Restaurando mundo..."
sudo rsync -av --progress --delete --exclude="logs" "$BACKUP_PATH/" "$WORLD_DIR/"
echo "Restauración completada con éxito."
