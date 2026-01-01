#!/bin/bash
set -e

# Render nginx config from template using env vars
envsubst '${DOMAIN_NAME}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Create self-signed cert if missing
if [ ! -f /etc/ssl/certs/inception.crt ] || [ ! -f /etc/ssl/private/inception.key ]; then
  mkdir -p /etc/ssl/certs /etc/ssl/private
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/inception.key \
    -out /etc/ssl/certs/inception.crt \
    -subj "/C=DE/ST=Berlin/L=Berlin/O=42/OU=Inception/CN=${DOMAIN_NAME}"
fi

exec "$@"