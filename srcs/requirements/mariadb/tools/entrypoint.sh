#!/bin/sh
set -eu

file_env() {
  var="$1"
  file_var="${var}_FILE"
  eval "val=\${$var-}"
  eval "file_val=\${$file_var-}"
  if [ -n "$val" ] && [ -n "$file_val" ]; then
    echo "Both $var and $file_var are set. Please set only one." >&2
    exit 1
  fi
  if [ -n "$file_val" ]; then
    val="$(cat "$file_val")"
  fi
  if [ -z "$val" ]; then
    echo "$var is not set" >&2
    exit 1
  fi
  export "$var"="$val"
}

file_env MYSQL_ROOT_PASSWORD
file_env MYSQL_PASSWORD
: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"

# Ensure runtime dir exists for socket
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# init only if empty volume
if [ ! -d "/var/lib/mysql/mysql" ]; then
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql

  # Start temporarily for bootstrap
  mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
  pid="$!"

  # Wait for server socket
  for i in $(seq 1 30); do
    mariadb-admin ping --silent && break
    sleep 1
  done

  mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
  mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
  mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
  mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
  mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

  mariadb-admin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
  wait "$pid" || true
fi

exec "$@"
