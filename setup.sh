#!/bin/bash

# 优先从命令行第一个参数获取 URL，如果没有再询问
KUMA_URL=$1

if [ -z "$KUMA_URL" ]; then
    read -p "请输入 Uptime Kuma 的 Push URL: " KUMA_URL
fi

# 再次检查，防止用户直接回车跳过
if [ -z "$KUMA_URL" ]; then
    echo "错误: 必须输入 URL"
    echo "用法: curl -sSL ... | bash -s -- '你的URL'"
    exit 1
fi

# 创建文件夹并进入
FOLDER_NAME="uptime-kuma-heartbeat"
mkdir -p "$FOLDER_NAME"
cd "$FOLDER_NAME" || exit

# 创建 docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3.8'
services:
  kuma-heartbeat:
    image: tano26/kuma-heartbeat:latest
    container_name: kuma-heartbeat
    restart: always
    dns:
      - 119.29.29.29
      - 8.8.8.8
    environment:
      - UPTIME_KUMA_URL=$KUMA_URL
      - INTERVAL_MINUTES=5
EOF

docker compose up -d
echo "✅ 部署完成！"
