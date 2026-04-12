#!/bin/ash
set -e

# Allow command passthrough (advanced usage)
if [ "$#" -gt 0 ]; then
    echo "Running custom command: $@"
    exec "$@"
fi

# Defaults
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

# Timezone setup
echo "Timezone: $TZ"
if [ -f "/usr/share/zoneinfo/$TZ" ]; then
    ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
    echo "$TZ" > /etc/timezone
else
    echo "Invalid TZ: $TZ"
fi

# Logging (optional)
if [ -n "$LOG_FILE" ]; then
    echo "Logging to $LOG_FILE"
    mkdir -p "$(dirname "$LOG_FILE")"
    exec > >(tee -a "$LOG_FILE") 2>&1
fi

echo "Mode: $MODE"
echo "Countries: $COUNTRIES"
echo "Direction: $DIRECTION"
echo "Port rules: $PORT_RULES"
echo "State: $GEOIP_STATE"
echo "IP source: $IP_SOURCE"
echo "Schedule: $SCHEDULE"
echo "Reset: $RESET"
echo "Firewall backend: $FIREWALL_BACKEND"

# Ensure installed
if ! command -v geoip-shell >/dev/null 2>&1; then
    echo "geoip-shell not found!"
    exit 1
fi

# Optional reset
if [ "$RESET" = "true" ]; then
    echo "Resetting previous config..."
    geoip-shell uninstall || true
fi

# Build config
CONFIG_CMD="geoip-shell configure -D $DIRECTION -m \"$MODE\" -c \"$COUNTRIES\""

[ -n "$IP_SOURCE" ] && CONFIG_CMD="$CONFIG_CMD -u $IP_SOURCE"
[ -n "$SCHEDULE" ] && CONFIG_CMD="$CONFIG_CMD -s \"$SCHEDULE\""

# Firewall backend override (IMPORTANT ADDITION)
if [ -n "$FIREWALL_BACKEND" ]; then
    case "$FIREWALL_BACKEND" in
        nft|ipt)
            echo "Using firewall backend: $FIREWALL_BACKEND"
            CONFIG_CMD="$CONFIG_CMD -w $FIREWALL_BACKEND"
            ;;
        *)
            echo "Invalid FIREWALL_BACKEND: $FIREWALL_BACKEND"
            exit 1
            ;;
    esac
fi

echo "Running base configuration..."
echo "$CONFIG_CMD"
eval $CONFIG_CMD

# Apply port rules AFTER base config
if [ -n "$PORT_RULES" ]; then
    echo "Applying port rules..."
    for rule in $PORT_RULES; do
        echo "  -> $rule"
        geoip-shell configure -D "$DIRECTION" -p "$rule"
    done
fi

# Enable/disable
if [ "$GEOIP_STATE" = "on" ] || [ "$GEOIP_STATE" = "off" ]; then
    geoip-shell "$GEOIP_STATE"
else
    echo "Invalid GEOIP_STATE: $GEOIP_STATE"
    exit 1
fi

echo "geoip-shell ready."

# Show Status
SHOW_STATUS="${SHOW_STATUS:-false}"

if [ "$SHOW_STATUS" = "true" ]; then
    echo "==== GEOIP STATUS ===="

    if geoip-shell status -v; then
        echo "Status command executed successfully"
    else
        echo "ERROR: geoip-shell status failed"
        exit 1
    fi

    echo "======================"
fi

# Keep alive
tail -f /dev/null
