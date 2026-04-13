#!/bin/bash
# Sub2API 启动脚本
# 服务：Redis + Vector DB + Sub2API
# 管理后台: http://localhost:8888  账号: admin@admin.com / Xx283619.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "🚀 启动 Sub2API 网关服务..."
echo ""

# 创建网络（如果不存在）
if ! docker network ls | grep -q binghe-network; then
    echo "📡 创建 Docker 网络 binghe-network..."
    docker network create binghe-network
fi

# 启动依赖服务
echo "🔧 启动依赖服务（Redis + Vector DB）..."
docker-compose -f docker-compose-light.yml up -d \
  redis \
  vector_db

# 等待 vector_db 健康检查通过
echo "⏳ 等待 PostgreSQL 就绪..."
until docker-compose -f docker-compose-light.yml exec -T vector_db pg_isready -U postgres -q; do
    sleep 1
done
echo "  ✅ PostgreSQL 已就绪"

# 创建 sub2api 数据库（如果不存在）
echo "🗄️  初始化 sub2api 数据库..."
docker-compose -f docker-compose-light.yml exec -T vector_db \
  psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname='sub2api'" \
  | grep -q 1 \
  || docker-compose -f docker-compose-light.yml exec -T vector_db \
     psql -U postgres -c "CREATE DATABASE sub2api;"
echo "  ✅ 数据库已就绪"

# 启动 sub2api
echo "🔧 启动 Sub2API..."
docker-compose -f docker-compose-light.yml up -d sub2api

# 等待 sub2api 启动
echo "⏳ 等待 Sub2API 启动..."
sleep 5

echo ""
echo "✅ Sub2API 启动完成！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 服务访问地址："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🌐 Sub2API 管理后台: http://localhost:8888"
echo "      账号:            admin@admin.com"
echo "      密码:            Xx283619."
echo "  🔴 Redis:            localhost:6379  (DB 1)"
echo "  🗄️  Vector DB:        localhost:5432"
echo "      数据库名:         sub2api"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 提示："
echo "  - 查看运行状态: ./scripts/status.sh"
echo "  - 停止服务:     ./scripts/stop.sh sub2api"
echo ""
