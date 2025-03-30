#!/bin/bash

# Config
BACKUP_DIR="/path/to/backups"
BACKUP_GROUP="yourgroup"
BACKUP_TIMESTAMP=$(date -I)
BACKUP_USER="youruser"
BACKUPS_TO_KEEP="3"
BOOKSTACK_DIR="/var/www/bookstack"

# Check that user is root
[[ $EUID -ne 0 ]] && echo "This script must be run as root." >&2 && exit 1

# Check that the bookstack directory exists
[ ! -d "$BOOKSTACK_DIR" ] && echo "BookStack is not installed on this system." >&2 && exit 1

# Create backup files
tar -czf "$BACKUP_DIR"/"$BACKUP_TIMESTAMP"-files.tar.gz -C "$BOOKSTACK_DIR" .env public/uploads storage/uploads themes
mysqldump -u root bookstack > "$BACKUP_DIR"/"$BACKUP_TIMESTAMP"-database.sql

# Change ownership of backup files
chown -R "$BACKUP_USER":"$BACKUP_GROUP" "$BACKUP_DIR"

# Delete old backups once backup count is over BACKUPS_TO_KEEP variable
FILES_TO_KEEP=$(( BACKUPS_TO_KEEP * 2 ))
while (( $(ls -1 "$BACKUP_DIR" | wc -l) > "$FILES_TO_KEEP" )); do
  oldest_file=$(ls -1t "$BACKUP_DIR" | tail -1)
  rm -f "$BACKUP_DIR/$oldest_file"
done

date; echo "Backup completed!"
