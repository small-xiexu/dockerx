#!/bin/bash
# 状态查看脚本
# 用法：./status.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "📊 DockerX 服务状态"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# AI 开发环境服务
echo "🤖 AI 开发环境："
AI_SERVICES="redis ollama vector_db vector_db_admin"
for service in $AI_SERVICES; do
    if docker ps --format '{{.Names}}' | grep -q "^${service}$"; then
        status=$(docker ps --filter "name=^${service}$" --format "{{.Status}}")
        echo "  ✅ $service - $status"
    else
        echo "  ⭕ $service - 未运行"
    fi
done

echo ""
echo "💻 日常开发环境："
DEV_SERVICES="mysql redis"
for service in $DEV_SERVICES; do
    if docker ps --format '{{.Names}}' | grep -q "^${service}$"; then
        status=$(docker ps --filter "name=^${service}$" --format "{{.Status}}")
        echo "  ✅ $service - $status"
    else
        echo "  ⭕ $service - 未运行"
    fi
done

echo ""
echo "🌐 Sub2API 网关："
SUB2API_SERVICES="sub2api"
for service in $SUB2API_SERVICES; do
    if docker ps --format '{{.Names}}' | grep -q "^${service}$"; then
        status=$(docker ps --filter "name=^${service}$" --format "{{.Status}}")
        echo "  ✅ $service - $status"
    else
        echo "  ⭕ $service - 未运行"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 统计运行中的容器
RUNNING_COUNT=$(docker ps --format '{{.Names}}' | wc -l | tr -d ' ')
echo "📈 总计运行中的容器: $RUNNING_COUNT 个"
echo ""
