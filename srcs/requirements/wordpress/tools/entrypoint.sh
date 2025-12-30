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

file_env MYSQL_PASSWORD
file_env WP_ADMIN_PASSWORD
file_env WP_USER_PASSWORD
: "${DOMAIN_NAME:?DOMAIN_NAME is required}"
: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${WP_TITLE:?WP_TITLE is required}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"
: "${WP_USER:?WP_USER is required}"
: "${WP_USER_EMAIL:?WP_USER_EMAIL is required}"

# Enforce admin username rule (must not contain admin/Admin/administrator/etc)
echo "$WP_ADMIN_USER" | grep -i -E 'admin' && {
  echo "ERROR: WP_ADMIN_USER must NOT contain 'admin' or 'administrator'"; exit 1;
} || true

# If WP isn't present in the volume yet, download + configure
if [ ! -f wp-config.php ]; then
  wp core download --allow-root

  wp config create --allow-root \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="mariadb:3306"

  # Wait for DB
  for i in $(seq 1 30); do
    wp db check --allow-root && break
    sleep 1
  done

  wp core install --allow-root \
    --url="https://${DOMAIN_NAME}" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL"

  wp user create --allow-root \
    "$WP_USER" "$WP_USER_EMAIL" \
    --user_pass="$WP_USER_PASSWORD"
fi

exec "$@"
