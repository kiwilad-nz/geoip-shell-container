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

# Reset to avoid duplicate rules (safe fallback)
echo "Cleaning previous configuration (if any)..."
geoip-shell uninstall || true

# Build base configure command
CONFIG_CMD="geoip-shell configure -m \"$MODE\" -c \"$COUNTRIES\""

# Add IP source if provided
if [ -n "$IP_SOURCE" ]; then
    CONFIG_CMD="$CONFIG_CMD -u $IP_SOURCE"
fi

# Run base configuration FIRST
echo "Running base configuration..."
echo "$CONFIG_CMD"
eval $CONFIG_CMD

# Apply port/protocol rules AFTER base config
if [ -n "$PORT_RULES" ]; then
    echo "Applying port rules..."
    for rule in $PORT_RULES; do
        echo "  -> $rule"
        geoip-shell configure -p "$rule"
    done
fi

# Enable or disable filtering
if [ "$GEOIP_STATE" = "on" ] || [ "$GEOIP_STATE" = "off" ]; then
    echo "Setting geoip state: $GEOIP_STATE"
    geoip-shell "$GEOIP_STATE"
else
    echo "Invalid GEOIP_STATE: $GEOIP_STATE (expected 'on' or 'off')"
    exit 1
fi

echo "geoip-shell setup complete."

# Keep container alive (remove if using one-shot mode)
tail -f /dev/null
