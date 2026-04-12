FROM alpine:3.21

RUN apk add --no-cache \
    bash \
    curl \
    wget \
    iptables \
    ipset \
    nftables \
    grep \
    sed \
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

RUN wget -qO - https://github.com/friendly-bits/geoip-shell/archive/refs/heads/main.tar.gz \
    | tar -xz && mv geoip-shell-* geoip-shell

WORKDIR /opt/geoip-shell

RUN chmod +x *.sh

# Install using a compatible shell (important!)
RUN ash geoip-shell-install.sh -z

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
