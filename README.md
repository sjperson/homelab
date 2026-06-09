# homelab

Single-node homelab on consumer hardware.

## Hardware

- Lenovo IdeaPad 300-17ISK
- i3-6100U
- 8 GB DDR3L
- 500 GB HDD

## Stack

- Proxmox VE
- Debian 13
- LXC

## Architecture

```
[LAN Router]
     |
[USB WiFi]
     |
[Proxmox]
     |
     | (vmbr0 - <LXC_SUBNET_GATEWAY> - NAT)
     |
     ├── [LXC] <IP_LXC_RANGE>
     ├── [LXC] <IP_LXC_RANGE>
     └── ...
```

## Network

| Interface | Type | Description |
|---------|------|-------------|
| `<WIFI_INTERFACE>` | USB WiFi | Uplink to router |
| `vmbr0` | Virtual bridge | NAT, <LXC_SUBNET_GATEWAY> |

| Network | Range | Use |
|---------|-------|-----|
| LAN | `<LAN_SUBNET>` | Router + Proxmox host |
| Internal | `<LXC_SUBNET>` | LXCs via NAT |

## Access

| Method | Detail |
|--------|--------|
| Web UI | `https://<IP_HOST_LAN>:8006` |
| SSH | `root@<IP_HOST_LAN>` |

Post-install: `pve-no-subscription` repository, SSH via ed25519 key, password authentication disabled.

## Criteria

- LXC instead of VMs: lower overhead on limited hardware
- ext4 instead of ZFS: no ECC RAM, insufficient memory
- NAT over USB WiFi: 802.11 doesn't support bridging

## Services

| Service | LXC ID | IP | Status |
|---------|--------|----|--------|
| — | — | — | pending |