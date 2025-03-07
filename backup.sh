#!/bin/bash

MINECRAFT_SERVER_DIR="/home/carlos/server"
WORLD_DIR="$MINECRAFT_SERVER_DIR/world"
BACKUP_DIR="/home/carlos/dataswap/world_backup"
LOG_DIR="$BACKUP_DIR/logs"
LOG_FILE="$LOG_DIR/backup.log"
VERSION="1.17.1"

# Create log directories if they do not exist
mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_DIR"

# Register the version at the beginning of the log file
if [ ! -f "$LOG_FILE" ]; then
    echo "Version:$VERSION" >>"$LOG_FILE"
fi

# File that stores previous backups
PREV_BACKUPS_FILE="$LOG_DIR/prev_backups.list"
ls "$BACKUP_DIR" > "$PREV_BACKUPS_FILE" 2>/dev/null

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
        *) echo "Please enter 'y' or 'n'." ;;
        esac
    done

    timestamp=$(date "+%d-%m-%Y %I:%M:%S %p")
    read -p "Work done: " work_done
	backup_name="$(LC_TIME=en_US.UTF-8 date '+%d_%m_%Y_%I_%M_%S_%p')"

    # Check if the backup directory already exists
    if [ -d "$BACKUP_DIR/$backup_name" ]; then
        echo "Error: The backup folder '$backup_name' already exists. Changing name..."
        backup_name="${backup_name}_$(date '+%S')"  # Add seconds to avoid collision
    fi

    mkdir -p "$BACKUP_DIR/$backup_name"
    rsync -a --progress "$WORLD_DIR/" "$BACKUP_DIR/$backup_name/"
    echo "Backup successfully created at: $BACKUP_DIR/$backup_name"
    echo "$timestamp [Saved] [$work_done]" >>"$LOG_FILE"

    # Detect manually deleted backups
    current_backups=$(ls "$BACKUP_DIR" 2>/dev/null)
    while read -r prev_backup; do
        if [[ ! -d "$BACKUP_DIR/$prev_backup" ]]; then
            echo "$timestamp [Deleted] [$prev_backup] (Manual deletion)" >>"$LOG_FILE"
        fi
    done < "$PREV_BACKUPS_FILE"

    # Save the current state of backups
    ls "$BACKUP_DIR" > "$PREV_BACKUPS_FILE" 2>/dev/null

    # Delete old backups (older than 7 days) and log them
    find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +7 | while read -r old_backup; do
        echo "$timestamp [Deleted] [$old_backup] (Automatic deletion)" >>"$LOG_FILE"
        rm -rf "$old_backup"
    done
}

# Execute backup directly
backup
