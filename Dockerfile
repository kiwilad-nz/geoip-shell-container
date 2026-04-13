FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    iptables \
    ipset \
    nftables \
    gawk \
    coreutils \
    procps \
    util-linux \
    tzdata \
    ca-certificates \
    grep \
    gzip \
    unzip \
    cron \
    busybox \
    bash \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN curl -fsSL https://github.com/friendly-bits/geoip-shell/archive/refs/heads/main.tar.gz \
    | tar -xz && mv geoip-shell-* geoip-shell

WORKDIR /opt/geoip-shell

RUN chmod +x *.sh

# Install geoip-shell (non-interactive)
RUN ash geoip-shell-install.sh -z

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
