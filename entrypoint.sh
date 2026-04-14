#!/bin/sh
# Initialize cron
crond
# ----------------------------
# LOG WRAPPER (MUST BE FIRST)
# ----------------------------
geoip-shell() {
  command geoip-shell "$@" >> /proc/1/fd/1 2>> /proc/1/fd/2
}
# ----------------------------
# INSTALL
# ----------------------------
echo Installing geoip-shell
./geoip-shell-install.sh -z
echo "Fetching version..."
VERSION="$(command geoip-shell -V)"
echo "Version: $VERSION Installed"
# ----------------------------
# CONFIGURE
# ----------------------------
if grep -qE '^[^#[:space:]]' /etc/geoip-shell/geoip-shell.conf; then
  echo "Saved config found → running geoip-shell configure"
  echo "Selecting option: KEEP (k)"
  printf "k\n" | command geoip-shell configure
  echo "Setup complete"
else
  echo "No saved config → skipped running geoip-shell configure"
fi
# ----------------------------
# STATUS
# ----------------------------
command geoip-shell status
# ----------------------------
# KEEP ALIVE
# ----------------------------
tail -f /dev/null
