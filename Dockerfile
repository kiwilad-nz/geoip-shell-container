# Use Alpine as the base image
FROM alpine:latest

# Install the required packages
RUN apk update && \
    apk add --no-cache \
    bash \
    curl \
    wget \
    jq \
    nftables \
    iptables \
    ipset \
    ca-certificates \
    coreutils \
    findutils \
    grep \
    sed \
    gawk \
    tzdata \
    dcron \
    envsubst \
    libcap-setcap

# Download the latest release of geoip-shell
RUN curl -L "$(curl -s https://api.github.com/repos/friendly-bits/geoip-shell/releases | grep -m1 -o 'https://api.github.com/repos/friendly-bits/geoip-shell/tarball/[^"]*')" > geoip-shell.tar.gz && \
    tar -zxvf geoip-shell.tar.gz && \
    rm geoip-shell.tar.gz

RUN export GEOIP_SHELL_DIR=$(find . -maxdepth 1 -type d -name 'friendly-bits-geoip-shell*' -print -quit) && \
    echo "Extracted directory: $GEOIP_SHELL_DIR" && \
    cd $GEOIP_SHELL_DIR && \
    # Make all .sh files executable (in case new ones are added)
    chmod +x *.sh

# Install geoip-shell (non-interactiv
RUN export GEOIP_SHELL_DIR=$(find . -maxdepth 1 -type d -name 'friendly-bits-geoip-shell*' -print -quit) && \
    cd $GEOIP_SHELL_DIR && \
    ./geoip-shell-install.sh -z

# Clean up apk cache to reduce image size
RUN rm -rf /var/cache/apk/*

RUN setcap cap_net_admin,cap_net_raw+ep /usr/sbin/xtables-nft-multi && \
    setcap cap_net_admin,cap_net_raw+ep /usr/sbin/ipset && \
    chmod 1777 /run

COPY --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
