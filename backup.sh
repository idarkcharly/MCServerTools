#!/bin/bash

MINECRAFT_SERVER_DIR="/home/carlos/server"
WORLD_DIR="$MINECRAFT_SERVER_DIR/world"
BACKUP_DIR="/home/carlos/dataswap/world_backup"
LOG_DIR="$BACKUP_DIR/logs"
LOG_FILE="$LOG_DIR/backup.log"
VERSION="1.17.1"

mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_DIR"

if [ ! -f "$LOG_FILE" ]; then
    echo "Version:$VERSION" >>"$LOG_FILE"
fi

PREV_BACKUPS_FILE="$LOG_DIR/prev_backups.list"

backup() {
    while true; do
        read -p "Do you want to create a backup? (y/n): " confirm
        case $confirm in
            [Yy]*) break ;;
            [Nn]*)
                timestamp=$(date "+%d-%m-%Y %I:%M:%S %p")
                read -p "Reason for not saving: " reason
                echo "$timestamp [Ignored] [$reason]" >>"$LOG_FILE"
                echo "Backup canceled."
                return 0
                ;;
            *) echo "Please enter 'y' or 'n'."
		continue;;
        esac
    done

    timestamp=$(date "+%d-%m-%Y %I:%M:%S %p")
    read -p "Work done: " work_done
    backup_name="$(LC_TIME=en_US.UTF-8 date '+%d_%m_%Y_%I_%M_%S_%p')"

    if [ -d "$BACKUP_DIR/$backup_name" ]; then
        backup_name="${backup_name}_$(date '+%S')"
    fi

    mkdir -p "$BACKUP_DIR/$backup_name"
    rsync -a --progress "$WORLD_DIR/" "$BACKUP_DIR/$backup_name/"
    echo "Backup successfully created at: $BACKUP_DIR/$backup_name"
    echo "$timestamp [Saved] [$work_done]" >>"$LOG_FILE"

    # Detect manual deletions
    echo "Checking for manual deletions..."
    while read -r prev_backup; do
        if [ ! -d "$prev_backup" ] && [ -n "$prev_backup" ]; then
            echo "$timestamp [Deleted] [$(basename "$prev_backup")] (Manual deletion)" >>"$LOG_FILE"
            echo "Detected deleted backup: $(basename "$prev_backup")"
        fi
    done < "$PREV_BACKUPS_FILE"

    # Automatic deletion (older than 7 days)
    echo "Checking for automatic deletions..."
    find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec bash -c 'echo "$1 [Deleted] [$(basename "$0")] (Automatic deletion)" >> "$LOG_FILE"; rm -rf "$0"' {} "$timestamp" \;

    # Save state at the END
    find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d ! -name "logs" | sed 's:/*$::' > "$PREV_BACKUPS_FILE" 2>/dev/null
}

backup
