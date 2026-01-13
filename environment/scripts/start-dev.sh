#!/bin/bash
# 日常开发环境启动脚本
# 服务：MySQL + Redis

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "💻 启动日常开发环境..."
echo ""

# 创建网络（如果不存在）
if ! docker network ls | grep -q binghe-network; then
    echo "📡 创建 Docker 网络 binghe-network..."
    docker network create binghe-network
fi

# 启动服务
echo "🔧 启动服务中..."
docker-compose -f docker-compose-light.yml up -d \
  mysql \
  redis

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 3

# 检查服务状态
echo ""
echo "✅ 日常开发环境启动完成！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 服务访问地址："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🗄️  MySQL:      localhost:3306"
echo "      用户名/密码: root/root"
echo "  🔴 Redis:       localhost:6379"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 提示："
echo "  - 查看运行状态: ./scripts/status.sh"
echo "  - 停止环境:     ./scripts/stop.sh dev"
echo ""
