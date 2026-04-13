#!/bin/sh
set -e

if [ "$#" -gt 0 ]; then
    exec "$@"
fi

MODE="${MODE:-whitelist}"
COUNTRIES="${COUNTRIES:-NZ}"
PORT_RULES="${PORT_RULES:-}"
GEOIP_STATE="${GEOIP_STATE:-on}"
IP_SOURCE="${IP_SOURCE:-}"
DIRECTION="${DIRECTION:-inbound}"
SCHEDULE="${SCHEDULE:-}"
TZ="${TZ:-UTC}"
RESET="${RESET:-false}"
LOG_FILE="${LOG_FILE:-}"
FIREWALL_BACKEND="${FIREWALL_BACKEND:-}"

echo "Starting geoip-shell..."
echo "Mode=$MODE Countries=$COUNTRIES Direction=$DIRECTION"

# timezone
if [ -f "/usr/share/zoneinfo/$TZ" ]; then
    ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
    echo "$TZ" > /etc/timezone
fi

# logging
if [ -n "$LOG_FILE" ]; then
    mkdir -p "$(dirname "$LOG_FILE")"
    exec > >(tee -a "$LOG_FILE") 2>&1
fi

# uninstall/reset
if [ "$RESET" = "true" ]; then
    echo "Reset enabled..."
    geoip-shell uninstall || true
fi

echo "Applying base config..."

geoip-shell configure -D "$DIRECTION" \
    -m "$MODE" \
    -c "$COUNTRIES"

if [ -n "$IP_SOURCE" ]; then
    geoip-shell configure -D "$DIRECTION" -u "$IP_SOURCE"
fi

if [ -n "$SCHEDULE" ]; then
    geoip-shell configure -s "$SCHEDULE"
fi

if [ -n "$FIREWALL_BACKEND" ]; then
    case "$FIREWALL_BACKEND" in
        nft|ipt)
            geoip-shell configure -w "$FIREWALL_BACKEND"
            ;;
        *)
            echo "Invalid FIREWALL_BACKEND"
            exit 1
            ;;
    esac
fi

# apply port rules
if [ -n "$PORT_RULES" ]; then
    echo "Applying port rules..."
    for rule in $PORT_RULES; do
        geoip-shell configure -D "$DIRECTION" -p "$rule"
    done
fi

geoip-shell "$GEOIP_STATE"

echo "geoip-shell ready"

# status
if [ "${SHOW_STATUS:-false}" = "true" ]; then
    geoip-shell status -v || true
fi

# keep alive (container pattern)
tail -f /dev/null
