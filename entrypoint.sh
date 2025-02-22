#!/bin/sh

# 如果没有 smb.conf，创建一个基本配置
if [ ! -f /etc/samba/smb.conf ]; then
    cat > /etc/samba/smb.conf <<EOL
[global]
    workgroup = WORKGROUP
    server string = Samba Server
    server role = standalone server
    log file = /var/log/samba/log.%m
    max log size = 50
    dns proxy = no
    
[share]
    comment = Default Share
    path = /share
    browseable = yes
    read only = no
    guest ok = yes
    create mask = 0644
    directory mask = 0755
EOL
fi

# 确保共享目录存在
mkdir -p /share
chmod 777 /share

# 启动 Samba 服务
exec smbd --foreground --no-process-group
