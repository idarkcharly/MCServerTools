#!/bin/bash

MINECRAFT_SERVER_DIR="/home/carlos/server"
WORLD_DIR="$MINECRAFT_SERVER_DIR/world"
BACKUP_DIR="/home/carlos/dataswap/world_backup"

# Check if backups exist

if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
    echo "No backups available in $BACKUP_DIR."
    exit 1
fi

# List backups (excluding "logs")
echo "Available backups:"
mapfile -t BACKUPS < <(find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d ! -name "logs" -printf "%f\n")

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "No backups available (except logs)."
    exit 1
fi

select backup in "${BACKUPS[@]}"; do
    if [ -n "$backup" ]; then
        BACKUP_PATH="$BACKUP_DIR/$backup"
        echo "Restoring from: $BACKUP_PATH"
        break
    else
        echo "Invalid selection, try again."
    fi
done

# Confirm restoration

read -p "Are you sure you want to restore '$backup' to '$WORLD_DIR'? (y/n): " confirm
if [[ "$confirm" =~ ^[Nn]$ ]]; then
    echo "Restoration canceled."
    exit 0
fi

# Restore with rsync (excluding "logs")

echo "Restoring world..."
sudo rsync -av --progress --delete --exclude="logs" "$BACKUP_PATH/" "$WORLD_DIR/"
echo "Restoration completed successfully."

