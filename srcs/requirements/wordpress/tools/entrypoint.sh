#!/bin/bash
set -e

DB_PW_FILE="${MYSQL_PASSWORD_FILE:-}"
CREDS_FILE="${WP_CREDENTIALS_FILE:-}"

# Require secrets to exist
if [ -z "$DB_PW_FILE" ] || [ ! -f "$DB_PW_FILE" ]; then
  echo "Missing MYSQL_PASSWORD_FILE secret"
  exit 1
fi
if [ -z "$CREDS_FILE" ] || [ ! -f "$CREDS_FILE" ]; then
  echo "Missing WP_CREDENTIALS_FILE secret"
  exit 1
fi

# Load secrets
MYSQL_PASSWORD="$(cat "$DB_PW_FILE")"
WP_ADMIN_PASSWORD="$(sed -n '1p' "$CREDS_FILE")"
WP_USER_PASSWORD="$(sed -n '2p' "$CREDS_FILE")"
WP_SITE_URL="https://${DOMAIN_NAME}"
if [ -n "${HTTPS_PORT:-}" ] && [ "${HTTPS_PORT}" != "443" ]; then
  WP_SITE_URL="${WP_SITE_URL}:${HTTPS_PORT}"
fi

# Download WP core on first boot of an empty volume
if [ ! -f "wp-load.php" ]; then
  echo "Downloading WordPress..."
  wp core download --allow-root
fi

# Wait for MariaDB to accept connections
echo "Waiting for MariaDB..."
for i in $(seq 1 60); do
  if mariadb-admin -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" ping >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Initial install only if config is missing
if [ ! -f "wp-config.php" ]; then
  echo "Creating wp-config.php..."
  wp config create \
    --allow-root \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="${MYSQL_HOST}:3306"

  echo "Installing WordPress..."
  wp core install \
    --allow-root \
    --url="${WP_SITE_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}"

  echo "Creating regular user..."
  wp user create \
    --allow-root \
    "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}"
fi

# Keep URLs in sync with HTTPS and port overrides so WordPress doesn't redirect to stale http/port values
echo "Ensuring site URL is ${WP_SITE_URL}..."
wp option update home "${WP_SITE_URL}" --allow-root >/dev/null
wp option update siteurl "${WP_SITE_URL}" --allow-root >/dev/null

# Restore ownership for php-fpm
chown -R www-data:www-data /var/www/html

exec "$@"
