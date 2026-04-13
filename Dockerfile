FROM alpine:3.21

# Install only what's actually needed
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    nftables \
    iptables \
    ipset \
    ca-certificates \
    tzdata \
    dcron \
    libcap

# Fetch latest release safely
RUN curl -s https://api.github.com/repos/friendly-bits/geoip-shell/releases/latest \
    | jq -r .tarball_url \
    | xargs curl -L -o geoip-shell.tar.gz && \
    tar -xzf geoip-shell.tar.gz && \
    rm geoip-shell.tar.gz && \
    GEOIP_DIR=$(find . -maxdepth 1 -type d -name "friendly-bits-geoip-shell*") && \
    mv "$GEOIP_DIR" /opt/geoip-shell

WORKDIR /opt/geoip-shell
RUN chmod +x *.sh

# Only needed if NOT using privileged mode
RUN setcap cap_net_admin,cap_net_raw+ep /usr/sbin/ipset || true

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
