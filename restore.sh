#!/bin/bash

# Directory where backups are stored
BACKUP_DIR="/home/carlos/dataswap/world_backup"

# Get a list of backups excluding "logs"
BACKUPS=($(find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d ! -name "logs" -printf "%T@ %p\n" | sort -nr | cut -d' ' -f2-))

# Check if there are available backups
if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "No backups found."
    exit 1
fi

# Main menu: Restore or Delete
echo "What would you like to do?"
echo "1) Restore a backup"
echo "2) Delete backups"
read -p "Select an option [1-2]: " ACTION

case "$ACTION" in
    1)  # Restore option
        LATEST_BACKUP=$(basename "${BACKUPS[0]}")
        echo "The most recent backup is: $LATEST_BACKUP"

        # If only one backup exists, restore it automatically
        if [ ${#BACKUPS[@]} -eq 1 ]; then
            echo "Automatically restoring from: $LATEST_BACKUP"
            rsync -a --progress "${BACKUPS[0]}/" "/home/carlos/server/world/"
            echo "Restore completed."
            exit 0
        fi

        # List available backups for selection
        echo "Select a backup to restore:"
        select backup in "${BACKUPS[@]}"; do
            if [[ -n "$backup" ]]; then
                echo "Restoring from: $(basename "$backup")"
                rsync -a --progress "$backup/" "/home/carlos/server/world/"
                echo "Restore completed."
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done
        ;;

    2)  # Delete backups option
        echo "List of available backups:"
        for i in "${!BACKUPS[@]}"; do
            echo "$((i+1))) $(basename "${BACKUPS[$i]}")"
        done

        read -p "Enter the numbers of the backups to delete (comma-separated): " DELETE_INPUT

        # Convert input to an array and delete selected backups
        IFS=',' read -ra DELETE_SELECTIONS <<< "$DELETE_INPUT"

        for num in "${DELETE_SELECTIONS[@]}"; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#BACKUPS[@]}" ]; then
                BACKUP_TO_DELETE="${BACKUPS[$((num-1))]}"
                echo "Deleting: $(basename "$BACKUP_TO_DELETE")"
                rm -rf "$BACKUP_TO_DELETE"
            else
                echo "Invalid number: $num (ignored)."
            fi
        done

        echo "Deletion process completed."
        ;;
        
    *)  
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac
