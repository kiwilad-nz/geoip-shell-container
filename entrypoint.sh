#!/bin/sh
# Initialize cron
crond
# ----------------------------
# LOG WRAPPER (MUST BE FIRST)
# ----------------------------
geoip-shell() {
  echo "[geoip-shell] $*" >&2
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
  echo "Saved config found → running auto-configure"
  echo "Selecting option: KEEP (k)"
  printf "k\n" | geoip-shell configure
  echo "Setup complete"
else
  echo "No saved config → skipping auto-configure"
  echo "Use 'geoip-shell configure' manually if needed"
  echo "Setup incomplete"
fi
# ----------------------------
# STATUS
# ----------------------------
command geoip-shell status
# ----------------------------
# KEEP ALIVE
# ----------------------------
tail -f /dev/null
