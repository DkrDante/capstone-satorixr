#!/bin/bash

SOURCE="$1"
BACKUP_DIR="$HOME/Desktop/devka14/capstone-satorixr/capstone/backups"
LOG_FILE="$HOME/Desktop/devka14/capstone-satorixr/capstone/logs/backup.log"

TIMESTAMP=$(date +"%Y-%m-%d-%H%M")
ARCHIVE_NAME="backup-${TIMESTAMP}.tar.gz"

if [ -z "$SOURCE" ]; then
  echo "ERROR: source directory not provided"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: source directory not provided" >>"$LOG_FILE"
  exit 1
fi

if [ ! -d "$SOURCE" ]; then
  echo "ERROR: source directory does not exist: $SOURCE"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: source directory does not exist: $SOURCE" >>"$LOG_FILE"
  exit 1
fi

if tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: archived $SOURCE → $ARCHIVE_NAME" >>"$LOG_FILE"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: failed to archive $SOURCE" >>"$LOG_FILE"
  exit 1
fi

find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -delete
