#!/bin/bash
set -e

ROOT_PW_FILE="${MYSQL_ROOT_PASSWORD_FILE:-}"
USER_PW_FILE="${MYSQL_PASSWORD_FILE:-}"

# Avoid client tools picking up MYSQL_HOST from the shared .env; force socket connections
unset MYSQL_HOST MYSQL_PWD MYSQL_TCP_PORT

if [ -z "$ROOT_PW_FILE" ] || [ ! -f "$ROOT_PW_FILE" ]; then
  echo "Missing MYSQL_ROOT_PASSWORD_FILE secret"
  exit 1
fi
if [ -z "$USER_PW_FILE" ] || [ ! -f "$USER_PW_FILE" ]; then
  echo "Missing MYSQL_PASSWORD_FILE secret"
  exit 1
fi

MYSQL_ROOT_PASSWORD="$(cat "$ROOT_PW_FILE")"
MYSQL_PASSWORD="$(cat "$USER_PW_FILE")"

# First-time init
DATA_DIR="/var/lib/mysql"
if [ ! -d "${DATA_DIR}/mysql" ]; then
  # In rootless setups the bind-mount may contain leftover files from a failed init.
  if [ "$(find "${DATA_DIR}" -mindepth 1 -maxdepth 1 | wc -l)" -ne 0 ]; then
    echo "Cleaning stale MariaDB data directory contents..."
    find "${DATA_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  fi

  echo "Initializing MariaDB datadir..."
  mariadb-install-db --user=mysql --basedir=/usr --datadir="${DATA_DIR}" > /dev/null

  echo "Starting MariaDB temporarily for setup..."
  mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
  tmp_mysqld_pid=$!

  # Wait until server is ready
  for i in $(seq 1 60); do
    if mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  echo "Configuring database and users..."
  mariadb --socket=/run/mysqld/mysqld.sock -uroot <<-SQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
SQL

  echo "Stopping temporary MariaDB..."
  mariadb-admin --socket=/run/mysqld/mysqld.sock -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

exec "$@"
