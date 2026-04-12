# geoip-shell-container
Containerized version of friendly-bits/geoip-shell

## Environment Variables

| Variable    | Description                   | Example         |
| ----------- | ----------------------------- | --------------- |
| MODE        | whitelist or blacklist        | whitelist       |
| COUNTRIES   | Comma-separated country codes | NZ,AU           |
| PORT_RULES  | Protocol/port rules           | tcp:block:22,80 |
| GEOIP_STATE | Enable or disable rules       | on / off        |
| IP_SOURCE   | IP list provider              | ipdeny          |

### Example

```bash
docker run \
  --network host \
  --cap-add NET_ADMIN \
  --privileged \
  -e MODE=blacklist \
  -e COUNTRIES=CN,RU \
  -e PORT_RULES="tcp:block:22,80" \
  -e GEOIP_STATE=on \
  geoip-shell
```
