#!/bin/sh

set -eu

MYSQL_HOST="${MYSQL_HOST:-mysql}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-root}"
MYSQL_DATABASE="${MYSQL_DATABASE:-nacos_config}"
NACOS_INIT_SQL="${NACOS_INIT_SQL:-/init-sql/nacos_init.sql}"

export MYSQL_PWD="${MYSQL_PASSWORD}"

mysql_exec() {
  mysql \
    --protocol=TCP \
    --host="${MYSQL_HOST}" \
    --port="${MYSQL_PORT}" \
    --user="${MYSQL_USER}" \
    --batch \
    --skip-column-names \
    "$@"
}

echo "Waiting for MySQL at ${MYSQL_HOST}:${MYSQL_PORT} ..."
until mysqladmin ping \
  --protocol=TCP \
  --host="${MYSQL_HOST}" \
  --port="${MYSQL_PORT}" \
  --user="${MYSQL_USER}" \
  --silent; do
  sleep 2
done

echo "Ensuring database ${MYSQL_DATABASE} exists ..."
mysql_exec -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

table_exists="$(mysql_exec -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}' AND table_name='config_info';")"

if [ "${table_exists}" = "0" ]; then
  echo "Initializing schema for ${MYSQL_DATABASE} ..."
  mysql_exec "${MYSQL_DATABASE}" < "${NACOS_INIT_SQL}"
  echo "Nacos schema initialized."
else
  echo "Schema already exists in ${MYSQL_DATABASE}, skipping import."
fi
