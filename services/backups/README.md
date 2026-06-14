# Backups

Automated LXC backups to Google Drive via rclone.

## Flow

```
vzdump (LXC dump) => /var/lib/vz/dump => rclone sync => gdrive:homelab-backups
```

## Schedule

Daily at 3:00 AM via cron on the Proxmox host.

## Retention

Local backups older than 7 days are deleted automatically.
Remote backups on Google Drive are kept indefinitely.

## LXCs backed up

| LXC ID | Hostname |
|--------|----------|
| 100 | vpn |
| 101 | dns |
| 102 | monitor |

## Decisions

- rclone over PBS: simpler setup, no extra server required
- Google Drive: 5 TB available, offsite by default
- zstd compression: best ratio/speed tradeoff for vzdump
- snapshot mode: backup without stopping the LXC
- Local retention 7 days: balance between disk usage and recovery window

## Setup

### 1. Install rclone

```bash
apt install -y rclone
```

### 2. Configure Google Drive remote

```bash
rclone config
```

- Name: `gdrive`
- Storage: Google Drive
- Scope: full access
- Auto config: `n` (headless server — authorize from another machine)

```bash
# On a machine with a browser
rclone authorize "drive" "<token>"
```

Paste the result back in Proxmox.

### 3. Create remote directory

```bash
rclone mkdir gdrive:homelab-backups
```

### 4. Deploy backup script

Copy `examples/homelab-backup.sh` to `/usr/local/bin/homelab-backup.sh` and make it executable:

```bash
chmod +x /usr/local/bin/homelab-backup.sh
```

### 5. Schedule with cron

```bash
crontab -e
```

Add:

```
0 3 * * * /usr/local/bin/homelab-backup.sh >> /var/log/homelab-backup.log 2>&1
```

## Examples

| File | Destination |
|------|-------------|
| `examples/homelab-backup.sh` | `/usr/local/bin/homelab-backup.sh` on Proxmox host |