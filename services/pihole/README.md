# Pi-hole

DNS server with ad blocking and DNS over HTTPS via dnscrypt-proxy.

## LXC

| Param | Value |
|-------|-------|
| ID | `<LXC_DNS_ID>` |
| IP | `<LXC_DNS_IP>` |
| Hostname | dns |
| RAM | 256 MB |
| Disk | 4 GB |

## Access

- Web UI: `http://<LXC_DNS_IP>/admin` (requires VPN or LAN route)
- DNS port: 53 (UDP/TCP)

## DNS flow

```
client => Pi-hole (<LXC_DNS_IP>:53) => dnscrypt-proxy (127.0.0.1:5053) => Cloudflare DoH
```

VPN clients reach Pi-hole via DNAT in the WireGuard LXC — see `services/wireguard/README.md`.

LAN devices reach Pi-hole via the router DNS setting (`<LXC_DNS_IP>`).

<p align="center"><img src="../../docs/diagrams/dns-flow.drawio.png"/></p>

## Decisions

- Separate LXC from WireGuard: DNS available on LAN independently of VPN
- dnscrypt-proxy as upstream: DNS over HTTPS, ISP cannot see queries
- `listeningMode = ALL` in pihole.toml: required to accept DNAT-forwarded queries
- Pi-hole v6: config in `/etc/pihole/pihole.toml`
- Static route to `<VPN_SUBNET>` required so Pi-hole can reply to VPN clients

## Services

| Service | Port | Notes |
|---------|------|-------|
| pihole-FTL | 53 | enabled, auto-start |
| dnscrypt-proxy | 5053 (localhost) | enabled, auto-start, custom unit file |

## Installation

```bash
# 1. Pre-create config to run installer unattended
pct exec <LXC_DNS_ID> -- bash -c "
mkdir -p /etc/pihole
cat > /etc/pihole/setupVars.conf << 'VARS'
PIHOLE_INTERFACE=eth0
IPV4_ADDRESS=<LXC_DNS_IP>/24
IPV6_ADDRESS=
QUERY_LOGGING=true
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
LIGHTTPD_ENABLED=true
CACHE_SIZE=10000
DNS_FQDN_REQUIRED=true
DNS_BOGUS_PRIV=true
DNSMASQ_LISTENING=local
PIHOLE_DNS_1=1.1.1.1
PIHOLE_DNS_2=8.8.8.8
BLOCKING_ENABLED=true
WEBPASSWORD=
VARS
apt install -y dialog curl
curl -sSL https://install.pi-hole.net -o /tmp/install.sh
bash /tmp/install.sh --unattended
"

# 2. Set web admin password
pct exec <LXC_DNS_ID> -- bash -c "/usr/local/bin/pihole setpassword"

# 3. Install dnscrypt-proxy
pct exec <LXC_DNS_ID> -- bash -c "apt install -y dnscrypt-proxy"
```

Deploy `examples/dnscrypt-proxy.toml` and `examples/dnscrypt-proxy.service` to the LXC, then:

```bash
pct exec <LXC_DNS_ID> -- bash -c "
systemctl daemon-reload
systemctl enable --now dnscrypt-proxy
"
```

Configure Pi-hole upstream to `127.0.0.1#5053` via web UI (Settings => DNS).

Deploy `examples/network-interfaces-dns.conf` as `/etc/network/interfaces` and reboot the LXC.

## Examples

| File | Destination |
|------|-------------|
| `examples/dnscrypt-proxy.toml` | `/etc/dnscrypt-proxy/dnscrypt-proxy.toml` on LXC dns |
| `examples/dnscrypt-proxy.service` | `/etc/systemd/system/dnscrypt-proxy.service` on LXC dns |
| `examples/network-interfaces-dns.conf` | `/etc/network/interfaces` on LXC dns |
