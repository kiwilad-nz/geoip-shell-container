#!/bin/ash
set -e

MODE="${MODE:-whitelist}"
COUNTRIES="${COUNTRIES:-NZ}"
UPDATE_INTERVAL="${UPDATE_INTERVAL:-}"

echo "Starting geoip-shell..."
echo "Mode: $MODE"
echo "Countries: $COUNTRIES"

# Ensure command exists
if ! command -v geoip-shell >/dev/null 2>&1; then
    echo "geoip-shell not found!"
    exit 1
fi

# Apply configuration (idempotent enough for most cases)
geoip-shell configure -m "$MODE" -c "$COUNTRIES"

# Optional: enable cron updates
if [ -n "$UPDATE_INTERVAL" ]; then
    echo "Setting up cron with interval: $UPDATE_INTERVAL"

    echo "$UPDATE_INTERVAL geoip-shell update >/var/log/cron.log 2>&1" > /etc/crontabs/root
    crond
fi

echo "geoip-shell is running."

# Keep container alive
tail -f /dev/null
