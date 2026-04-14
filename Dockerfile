FROM alpine:3.21

# Install
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

# Fetch latest release of Geoip-shell
RUN curl -s https://api.github.com/repos/friendly-bits/geoip-shell/releases/latest \
    | jq -r .tarball_url \
    | xargs curl -L -o geoip-shell.tar.gz && \
    tar -xzf geoip-shell.tar.gz && \
    rm geoip-shell.tar.gz && \
    GEOIP_DIR=$(find . -maxdepth 1 -type d -name "friendly-bits-geoip-shell*") && \
    mv "$GEOIP_DIR" /opt/geoip-shell

# Makes scrripts executable
WORKDIR /opt/geoip-shell
RUN chmod +x *.sh

# Mount Entrypoint
COPY --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
