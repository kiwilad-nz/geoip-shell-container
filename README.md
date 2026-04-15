# geoip-shell

User-friendly and versatile geoblocker for Linux. Supports both nftables and iptables firewall management utilities.

The idea of this project is making geoblocking (i.e. restricting access from or to Internet addresses based on geolocation) easy on (almost) any Linux system, no matter which hardware, including desktop, server, container, VPS or router, while also being reliable and providing flexible configuration options for the advanced users.

If you find this project useful, please consider supporting the original developer by starring the main GeoIP Shell repository on GitHub:

https://github.com/friendly-bits/geoip-shell

For more detailed information and in-depth usage instructions, please refer to the documentation provided by the original author of GeoIP Shell.

# Requirements

This service requires elevated network permissions because it directly interacts with the Linux kernel networking stack (ipset, firewall rules, and raw packet operations).
| Requirement     | Purpose |
|----------------|--------|
| NET_ADMIN      | Required to modify firewall rules and ipset sets |
| NET_RAW        | Required for raw packet operations |
| host networking | Ensures rules apply to real host traffic |

## Docker Compose Requirements

```yaml
cap_add:
  - NET_ADMIN
  - NET_RAW
network_mode: host
```
## Setup

To set up the service, copy the Docker Compose configuration and modify it as needed for your environment.
```yaml
services:
  geoip-shell:
    build: https://github.com/kiwilad-nz/geoip-shell-container.git
    container_name: geoip-shell
    environment:
      TZ: Pacific/Auckland
    cap_add:
      - NET_ADMIN
      - NET_RAW
    network_mode: host
    volumes:
      - ./geoip-shell/config:/etc/geoip-shell
      - ./geoip-shell/backup:/var/lib/geoip-shell
    restart: unless-stopped
```
