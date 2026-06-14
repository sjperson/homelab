# Uptime Kuma

Service availability monitoring dashboard.

## LXC

| Param | Value |
|-------|-------|
| ID | `<LXC_MONITOR_ID>` |
| IP | `<LXC_MONITOR_IP>` |
| Hostname | monitor |
| RAM | 512 MB |
| Disk | 4 GB |

## Access

- Web UI: `http://<LXC_MONITOR_IP>:3001` (requires VPN or LAN route)

## Monitors

| Name | Type | Target |
|------|------|--------|
| WireGuard | Ping | `<LXC_VPN_IP>` |
| Pi-hole | HTTP | `http://<LXC_DNS_IP>/admin` |

## Decisions

- Docker: official deployment method for Uptime Kuma
- Only accessible via VPN: no reason to expose monitoring to the internet
- Ping for WireGuard: Uptime Kuma does not support UDP monitoring

## Installation

```bash
# Install Docker
pct exec <LXC_MONITOR_ID> -- bash -c "curl -fsSL https://get.docker.com | sh"

# Run Uptime Kuma
pct exec <LXC_MONITOR_ID> -- bash -c "
docker run -d \
  --name uptime-kuma \
  --restart=always \
  -p 3001:3001 \
  -v uptime-kuma:/app/data \
  louislam/uptime-kuma:1
"
```

First access: create admin user at `http://<LXC_MONITOR_IP>:3001`.
