#!/bin/bash
# Nacos 启动脚本
# 正确顺序：MySQL -> Nacos 数据库初始化 -> Nacos

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose -f docker-compose-light.yml)
else
  COMPOSE_CMD=(docker-compose -f docker-compose-light.yml)
fi

cd "$PROJECT_DIR"

echo "Starting Nacos with database bootstrap..."
echo "This script is the recommended entrypoint for Nacos."
echo ""

if ! docker network inspect binghe-network >/dev/null 2>&1; then
  echo "[1/4] Creating Docker network: binghe-network"
  docker network create binghe-network >/dev/null
else
  echo "[1/4] Docker network already exists: binghe-network"
fi

echo "[2/4] Starting MySQL"
"${COMPOSE_CMD[@]}" up -d mysql

echo "[3/4] Bootstrapping nacos_config with a temporary container"
"${COMPOSE_CMD[@]}" run --rm --no-deps nacos-db-init

echo "[4/4] Starting Nacos"
"${COMPOSE_CMD[@]}" up -d nacos

echo ""
echo "Nacos startup flow finished."
echo "Open: http://localhost:8848/nacos"
echo "Login: nacos / nacos"
echo ""
echo "Use ./scripts/start-nacos.sh next time."
echo "Do not start Nacos by clicking the nacos-db-init task in Docker Desktop."
