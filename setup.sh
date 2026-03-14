#!/bin/bash

# 1. 交互式获取 URL
read -p "请输入 Uptime Kuma 的 Push URL: " KUMA_URL

# 确保 URL 不为空
if [ -z "$KUMA_URL" ]; then
    echo "错误: 必须输入 URL"
    exit 1
fi

# 2. 创建文件夹并进入
FOLDER_NAME="uptime-kuma-heartbeat"
echo "正在创建文件夹: $FOLDER_NAME"
mkdir -p "$FOLDER_NAME"
cd "$FOLDER_NAME" || exit

# 3. 创建 docker-compose.yml 并写入配置
echo "正在生成 docker-compose.yml..."
cat <<EOF > docker-compose.yml
version: '3.8'
services:
  kuma-heartbeat:
    image: tano26/kuma-heartbeat:latest
    container_name: kuma-heartbeat
    restart: always
    environment:
      - UPTIME_KUMA_URL=$KUMA_URL
      - INTERVAL_MINUTES=5
EOF

# 4. 启动容器
echo "🚀 正在启动容器..."
docker compose up -d

echo "-----------------------------------"
echo "✅ 部署完成！"
echo "容器状态:"
docker compose ps
echo "查看日志请运行: cd $FOLDER_NAME && docker compose logs -f"
