#!/bin/bash
# 通用停止脚本
# 用法：
#   ./stop.sh           - 停止所有服务
#   ./stop.sh ai        - 停止 AI 开发环境
#   ./stop.sh dev       - 停止日常开发环境
#   ./stop.sh mysql     - 停止指定服务

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# AI 开发环境服务列表
AI_SERVICES="redis ollama vector_db pgadmin"

# 日常开发环境服务列表
DEV_SERVICES="mysql redis"

# Sub2API 服务列表
SUB2API_SERVICES="sub2api"

if [ $# -eq 0 ]; then
    # 没有参数，停止所有服务
    echo "🛑 停止所有服务..."
    docker-compose -f docker-compose-light.yml down
    echo "✅ 所有服务已停止"

elif [ "$1" = "ai" ]; then
    # 停止 AI 开发环境
    echo "🛑 停止 AI 开发环境..."
    docker-compose -f docker-compose-light.yml stop $AI_SERVICES
    docker-compose -f docker-compose-light.yml rm -f $AI_SERVICES
    echo "✅ AI 开发环境已停止"

elif [ "$1" = "dev" ]; then
    # 停止日常开发环境
    echo "🛑 停止日常开发环境..."
    docker-compose -f docker-compose-light.yml stop $DEV_SERVICES
    docker-compose -f docker-compose-light.yml rm -f $DEV_SERVICES
    echo "✅ 日常开发环境已停止"

elif [ "$1" = "sub2api" ]; then
    # 停止 Sub2API
    echo "🛑 停止 Sub2API..."
    docker-compose -f docker-compose-light.yml stop $SUB2API_SERVICES
    docker-compose -f docker-compose-light.yml rm -f $SUB2API_SERVICES
    echo "✅ Sub2API 已停止"

else
    # 停止指定服务
    echo "🛑 停止服务: $@"
    docker-compose -f docker-compose-light.yml stop "$@"
    docker-compose -f docker-compose-light.yml rm -f "$@"
    echo "✅ 服务已停止: $@"
fi
