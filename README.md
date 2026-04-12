# geoip-shell-docker

Containerized version of geoip-shell.

## ⚠️ Warning

This container modifies the host firewall and requires:

* `--privileged`
* `host network`
* NET_ADMIN capability

## Setup

```bash
cp .env.example .env
docker compose up -d --build
```

## Environment Variables

| Variable    | Description           |
| ----------- | --------------------- |
| MODE        | whitelist / blacklist |
| COUNTRIES   | Country codes         |
| DIRECTION   | inbound / outbound    |
| PORT_RULES  | Port/protocol rules   |
| GEOIP_STATE | on / off              |
| IP_SOURCE   | IP list provider      |
| SCHEDULE    | Cron schedule         |
| TZ          | Timezone              |
| RESET       | Reset config on start |
| LOG_FILE    | Optional log file     |

## CLI Usage

You can run commands directly:

```bash
docker run --rm --network host --privileged geoip-shell geoip-shell status
```

Examples:

```bash
docker run --rm --network host --privileged geoip-shell geoip-shell update
docker run --rm --network host --privileged geoip-shell geoip-shell restore
```

## Logs

```bash
docker logs -f geoip-shell
```

Optional file logs:

```bash
./logs/geoip-shell.log
```
