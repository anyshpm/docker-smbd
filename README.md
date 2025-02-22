# Docker Samba Server

[![CI](https://github.com/anyshpm/docker-smbd/actions/workflows/docker-buildx.yml/badge.svg)](https://github.com/anyshpm/docker-smbd/actions/workflows/docker-buildx.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/anyshpm/smbd.svg)](https://hub.docker.com/r/anyshpm/smbd)
[![Docker Image Size](https://img.shields.io/docker/image-size/anyshpm/smbd/latest.svg)](https://hub.docker.com/r/anyshpm/smbd)
[![GitHub License](https://img.shields.io/github/license/anyshpm/docker-smbd)](https://github.com/anyshpm/docker-smbd/blob/main/LICENSE)

基于 Alpine Linux 的轻量级 Samba 服务器 Docker 镜像。支持多架构，安全性高，配置灵活。

## 特性

- 基于 Alpine Linux 3.19
- 多架构支持：AMD64 和 ARM64
- 轻量级设计，镜像体积小
- 灵活的配置选项
- 容器签名验证
- 安全性优先
- 自动化构建和测试

## 系统要求

- Docker 20.10.0 或更高版本
- Docker Compose v2.0.0 或更高版本（可选）
- 至少 512MB RAM
- 50MB 磁盘空间（镜像）

## 快速开始

### 使用 Docker 运行

最简单的启动方式：

```bash
docker run -d \
    --name samba \
    --network host \
    -v /path/to/share:/share \
    anyshpm/smbd
```

使用指定用户 ID 运行：

```bash
docker run -d \
    --name samba \
    --network host \
    -e PUID=1000 \
    -e PGID=1000 \
    -v /path/to/share:/share \
    anyshpm/smbd
```

### 使用 Docker Compose

1. 创建项目目录：

```bash
mkdir samba-server && cd samba-server
mkdir -p {config,data/{lib,log},share}
```

2. 创建 docker-compose.yml：

```yaml
version: '3.8'

services:
  samba:
    image: anyshpm/smbd:latest
    container_name: samba
    restart: unless-stopped
    network_mode: host
    environment:
      - TZ=Asia/Shanghai
      - PUID=1000  # 指定用户ID
      - PGID=1000  # 指定组ID
    volumes:
      - ./config/smb.conf:/etc/samba/smb.conf:ro
      - ./data/lib:/var/lib/samba
      - ./data/log:/var/log/samba
      - ./share:/share
    healthcheck:
      test: ["CMD-SHELL", "smbclient -L \\\\localhost -U % -m SMB3"]
      interval: 1m
      timeout: 10s
      retries: 3
```

3. 启动服务：

```bash
docker compose up -d
```

## 配置

### 默认配置

容器首次启动时会自动创建默认配置文件，包含基本的共享设置。

### 自定义配置

创建自定义的 smb.conf 文件：

```ini
[global]
    workgroup = WORKGROUP
    server string = Samba Server
    server role = standalone server
    log file = /var/log/samba/log.%m
    max log size = 50
    dns proxy = no
    
[share]
    comment = Public Share
    path = /share
    browseable = yes
    read only = no
    guest ok = yes
    create mask = 0644
    directory mask = 0755
```

### 高级配置示例

1. 带用户认证的共享：

```ini
[secure]
    path = /share/secure
    valid users = @smbgroup
    guest ok = no
    writable = yes
    browseable = yes
```

2. 只读共享：

```ini
[readonly]
    path = /share/readonly
    read only = yes
    guest ok = yes
```

## 端口

| 端口 | 协议 | 描述 |
|------|------|------|
| 445 | TCP | SMB 直接托管 |
| 139 | TCP | NetBIOS 会话 |
| 137 | UDP | NetBIOS 名称服务 |
| 138 | UDP | NetBIOS 数据报 |

## 环境变量

| 变量名 | 描述 | 默认值 |
|--------|------|--------|
| TZ | 容器时区 | UTC |
| SMB_VERSION | Samba 版本 | 4.19.4-r0 |
| PUID | 指定运行用户的 UID | 1000 |
| PGID | 指定运行用户的 GID | 1000 |

## 存储卷

| 路径 | 描述 |
|------|------|
| /etc/samba | 配置目录 |
| /var/lib/samba | 数据目录 |
| /var/log/samba | 日志目录 |
| /share | 默认共享目录 |

## 版本标签

- `latest`: 最新稳定版本
- `vX.Y.Z`: 语义化版本
- `branch-*`: 开发分支版本
- `sha-*`: 提交版本

## 安全性

- 非特权容器运行
- 镜像签名验证
- 最小化安装
- 定期安全更新
- 资源限制

## 性能优化

1. 网络模式选择：
   - 推荐使用 host 网络模式获得最佳性能
   - 如需隔离，可使用端口映射模式

2. 存储优化：
   - 使用 volume 而非 bind mount
   - 考虑使用 tmpfs 挂载临时目录

## 常见问题

### 1. 访问权限问题

确保目录权限正确：

```bash
chmod -R 777 /path/to/share
```

### 2. 连接问题

检查防火墙设置：

```bash
sudo ufw allow 445/tcp
sudo ufw allow 139/tcp
sudo ufw allow 137/udp
sudo ufw allow 138/udp
```

### 3. 性能问题

优化 smb.conf 配置：

```ini
[global]
    socket options = TCP_NODELAY IPTOS_LOWDELAY
    read raw = yes
    write raw = yes
    strict locking = no
```

## 维护指南

### 更新镜像

```bash
docker compose pull
docker compose up -d
```

### 查看日志

```bash
docker compose logs -f samba
```

## 贡献指南

1. Fork 本仓库
2. 创建特性分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 相关链接

- [Docker Hub](https://hub.docker.com/r/anyshpm/smbd)
- [GitHub 仓库](https://github.com/anyshpm/docker-smbd)
- [问题反馈](https://github.com/anyshpm/docker-smbd/issues)
- [Alpine Linux](https://alpinelinux.org/)
- [Samba](https://www.samba.org/)

## 更新日志

### v1.0.0 (2024-03-xx)
- 初始发布
- 支持 AMD64 和 ARM64 架构
- 基于 Alpine 3.19
- 添加基本功能和配置选项

## 作者

**Anyshpm Chen**
- Email: anyshpm@anyshpm.com
- GitHub: [@anyshpm](https://github.com/anyshpm)

## 用户权限

### 使用自定义用户 ID

为了确保容器内外的文件权限一致，您可以通过设置 `PUID` 和 `PGID` 环境变量来指定运行 Samba 服务的用户 ID。这在以下情况特别有用：

1. 需要与主机系统用户权限保持一致
2. 多用户环境下的权限管理
3. NFS/共享存储的权限映射

示例：

```bash
# 查看当前用户的 UID 和 GID
id

# 使用当前用户的 UID 和 GID 运行容器
docker run -d \
    --name samba \
    --network host \
    -e PUID=$(id -u) \
    -e PGID=$(id -g) \
    -v /path/to/share:/share \
    anyshpm/smbd
```

### 权限问题排查

如果遇到权限相关问题，可以：

1. 确认 PUID/PGID 设置：
```bash
docker exec samba id
```

2. 检查目录权限：
```bash
ls -la /path/to/share
```

3. 调整目录权限：
```bash
chown -R $PUID:$PGID /path/to/share
```
