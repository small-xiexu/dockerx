#!/bin/bash
# AI 开发环境启动脚本
# 服务：Redis + Ollama + Vector DB + pgAdmin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "🤖 启动 AI 开发环境..."
echo ""

# 创建网络（如果不存在）
if ! docker network ls | grep -q binghe-network; then
    echo "📡 创建 Docker 网络 binghe-network..."
    docker network create binghe-network
fi

# 启动服务
echo "🔧 启动服务中..."
docker-compose -f docker-compose-light.yml up -d \
  redis \
  ollama \
  vector_db \
  pgadmin

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 3

# 检查服务状态
echo ""
echo "✅ AI 开发环境启动完成！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 服务访问地址："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔴 Redis:       localhost:6379"
echo "  🤖 Ollama:      http://localhost:11434"
echo "  🗄️  Vector DB:   localhost:5432"
echo "      用户名/密码: postgres/postgres"
echo "      数据库名:    ai-rag-knowledge"
echo "  🛠️  pgAdmin:     http://localhost:5050"
echo "      登录邮箱:    sj15814963053@gmail.com"
echo "      密码:        admin"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 提示："
echo "  - 查看运行状态: ./scripts/status.sh"
echo "  - 停止环境:     ./scripts/stop.sh ai"
echo ""
