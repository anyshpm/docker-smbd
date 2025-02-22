FROM alpine:3.21
LABEL maintainer="Anyshpm Chen<anyshpm@anyshpm.com>" \
    org.opencontainers.image.source="https://github.com/anyshpm/docker-smbd" \
    org.opencontainers.image.description="Samba Docker Image"

ARG SMB_VERSION=4.20.6-r1
ENV SMB_VERSION=${SMB_VERSION}

# 安装 samba 并清理缓存
RUN apk update \
    && apk add --no-cache \
        samba=${SMB_VERSION} \
        tzdata \
    && rm -rf /var/cache/apk/*

# 创建必要的目录
RUN mkdir -p /var/lib/samba \
    && mkdir -p /var/log/samba \
    && mkdir -p /var/run/samba \
    && mkdir -p /var/cache/samba

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/etc/samba", "/var/lib/samba", "/var/log/samba", "/share"]

EXPOSE 137/udp 138/udp 139/tcp 445/tcp

ENTRYPOINT ["/entrypoint.sh"]
