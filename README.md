# geoip-shell-docker

Containerized version of geoip-shell for host-level geoIP firewall filtering.

This container runs :contentReference[oaicite:0]{index=0} and applies firewall rules directly to the **host system** using `host networking` and `privileged access`.

---

## ⚠️ IMPORTANT WARNING

This container modifies the **host firewall directly**.

It requires:

- `--privileged`
- `--network host`
- NET_ADMIN / NET_RAW capabilities

### ❗ Misconfiguration risk:
- You can block SSH / remote access
- You can lock yourself out of the system

Use carefully on remote servers.

---

## 🧠 Architecture Overview

This container is NOT network-isolated.

It acts as a firewall controller:

.env → geoip-shell configure → host firewall rules applied

It manages:
- nftables or iptables rules
- IP sets
- geo-based filtering chains

---

## 🚀 Quick Start

```bash
cp .env.example .env
docker compose up -d --build

🌍 Environment Variables
Variable	Description
MODE	whitelist / blacklist
COUNTRIES	Country codes (e.g. NZ,AU,US)
DIRECTION	inbound / outbound
PORT_RULES	Space-separated port rules
GEOIP_STATE	on / off
IP_SOURCE	ripe / ipdeny / maxmind / ipinfo
FIREWALL_BACKEND	nft / ipt (default: nftables)
SCHEDULE	Cron schedule for updates
TZ	Timezone (e.g. Pacific/Auckland)
RESET	Remove existing geoip rules on startup
SHOW_STATUS	Show status after startup
LOG_FILE	Optional log file path
🔄 Lifecycle Behaviour
🟢 Normal startup (default)

RESET=false

Applies configuration from environment
Keeps existing firewall state if present
Updates rules if needed
🟡 Reset mode

RESET=true

On startup:

geoip-shell uninstall

Then:

configuration is re-applied
new rules are installed

✔ Clears old geoIP firewall state
❌ Does NOT uninstall geoip-shell software itself

🔴 Full uninstall (manual operation)

To completely remove geoIP firewall rules:

geoip-shell uninstall

Then stop container:

docker stop geoip-shell

🧹 Safe shutdown (recommended)

geoip-shell uninstall && docker stop geoip-shell

📌 Important Differences
Action	Effect
RESET=true	wipes geoIP firewall state, then reapplies config
geoip-shell uninstall	removes all geoIP firewall integration
docker stop	does NOT remove firewall rules
🖥️ CLI Usage

docker run --rm --network host --privileged geoip-shell geoip-shell status

Examples:

docker run --rm --network host --privileged geoip-shell geoip-shell status -v
docker run --rm --network host --privileged geoip-shell geoip-shell update
docker run --rm --network host --privileged geoip-shell geoip-shell restore
docker run --rm --network host --privileged geoip-shell geoip-shell off

📊 Logs

docker logs -f geoip-shell

Optional file logging:

./logs/geoip-shell.log

🧱 Firewall Backend
nft → nftables (recommended)
ipt → iptables (legacy fallback)

Default: nftables if available on host

🌐 Networking Model
host networking enabled
direct kernel firewall modification

❗ No container-level network isolation

🧠 Key Concepts
Concept	Meaning
Container	controller interface
geoip-shell	firewall engine
RESET	wipes current firewall state
uninstall	full removal of geoIP integration
stop container	does NOT affect firewall
🛡️ Recommended Production Settings

RESET=false
FIREWALL_BACKEND=nft
SHOW_STATUS=true

⚠️ Best Practices
Always test in a safe environment first
Ensure SSH access is allowed in rules
Prefer nft backend on modern systems
Use RESET sparingly
Verify rules after startup
🧩 Notes
nftables is default on modern Linux systems
iptables supported for compatibility
cron updates handled internally
rules apply directly to host firewall
