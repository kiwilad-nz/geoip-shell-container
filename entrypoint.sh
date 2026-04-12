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

# Keep alive
tail -f /dev/null
