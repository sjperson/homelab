#!/bin/bash
# ============================================================
# Homelab LXC backup script
# Destination: /usr/local/bin/homelab-backup.sh on Proxmox host
# Scheduled: daily at 3:00 AM via cron
# ============================================================

BACKUP_DIR=/var/lib/vz/dump
REMOTE=gdrive:homelab-backups
RETENTION_DAYS=7

# Dump LXCs
for ID in 100 101 102; do
    vzdump $ID --compress zstd --storage local --mode snapshot
done

# Sync to Google Drive
rclone sync $BACKUP_DIR $REMOTE --min-age 1m

# Remove local backups older than retention
find $BACKUP_DIR -name "*.zst" -mtime +$RETENTION_DAYS -delete
