FROM alpine:3.21

RUN apk add --no-cache \
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
    grep-cidr \
    gzip \
    unzip \
    cron

WORKDIR /opt

RUN curl -fsSL https://github.com/friendly-bits/geoip-shell/archive/refs/heads/main.tar.gz \
    | tar -xz && mv geoip-shell-* geoip-shell

WORKDIR /opt/geoip-shell

RUN chmod +x *.sh

# Install using ash (important)
RUN ash geoip-shell-install.sh -z

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
