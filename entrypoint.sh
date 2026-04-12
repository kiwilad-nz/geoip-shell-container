#!/bin/ash
set -e

MODE="${MODE:-whitelist}"
COUNTRIES="${COUNTRIES:-NZ}"
PORT_RULES="${PORT_RULES:-}"
GEOIP_STATE="${GEOIP_STATE:-on}"
IP_SOURCE="${IP_SOURCE:-}"

echo "Starting geoip-shell..."
echo "Mode: $MODE"
echo "Countries: $COUNTRIES"
echo "Port rules: $PORT_RULES"
echo "State: $GEOIP_STATE"
echo "IP source: $IP_SOURCE"

# Ensure installed
if ! command -v geoip-shell >/dev/null 2>&1; then
    echo "geoip-shell not found!"
    exit 1
fi

# Optional: reset to avoid duplication issues
geoip-shell uninstall || true

# Build configure command
CONFIG_CMD="geoip-shell configure -m \"$MODE\" -c \"$COUNTRIES\""

# Add port rules if provided
if [ -n "$PORT_RULES" ]; then
    CONFIG_CMD="$CONFIG_CMD -p $PORT_RULES"
fi

# Add IP source if provided
if [ -n "$IP_SOURCE" ]; then
    CONFIG_CMD="$CONFIG_CMD -u $IP_SOURCE"
fi

# Run configuration
echo "Running: $CONFIG_CMD"
eval $CONFIG_CMD

# Enable or disable filtering
if [ "$GEOIP_STATE" = "on" ] || [ "$GEOIP_STATE" = "off" ]; then
    echo "Setting geoip state: $GEOIP_STATE"
    geoip-shell "$GEOIP_STATE"
fi

echo "geoip-shell setup complete."

# Keep container alive
tail -f /dev/null
