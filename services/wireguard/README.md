# WireGuard + DDNS

Remote access VPN.

## LXC

| Param | Value |
|-------|-------|
| ID | `<LXC_VPN_ID>` |
| IP | `<LXC_VPN_IP>` |
| Hostname | vpn |
| RAM | 256 MB |
| Disk | 4 GB |

## Access

- Port: `<VPN_PORT>` UDP
- Domain: `<VPN_DDNS_DOMAIN>` (No-IP)

## DDNS

- Provider: No-IP
- Update: TP-Link TL-WR940N router, DDNS key

## Clients

| Name | VPN IP | Profile |
|------|--------|---------|
| pc-arch | `<VPN_CLIENT_PCARCH>` | wg0 (local), wg1 (external) |

## Decisions

- Combined LXC for WireGuard + DDNS (DDNS client runs on the router, not the LXC)
- wg0: local profile (Endpoint `<LXC_VPN_IP>`), AllowedIPs `<VPN_SUBNET>`
- wg1: external profile (Endpoint `<VPN_DDNS_DOMAIN>`), AllowedIPs 0.0.0.0/0
- Route `<LXC_SUBNET>` via `<IP_HOST_LAN>` required for local access

## Port forward

- ISP Gateway => `<ISP_GATEWAY_WAN>:<VPN_PORT>` UDP => `<IP_HOST_WAN>:<VPN_PORT>` (TP-Link WAN)
- TP-Link (`<ROUTER_IP>`) => `<IP_HOST_LAN>:<VPN_PORT>` UDP => Proxmox
- Proxmox DNAT: `<WIFI_INTERFACE>` => `<LXC_VPN_IP>:<VPN_PORT>`

## LXC NAT

- `iptables -t nat -A POSTROUTING -s <VPN_SUBNET> -o eth0 -j MASQUERADE`
- Persisted with `iptables-persistent`