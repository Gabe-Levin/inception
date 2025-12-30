#!/bin/sh
set -eu

mkdir -p /etc/nginx/ssl

: "${DOMAIN_NAME:?DOMAIN_NAME is required}"
sed -i "s/\${DOMAIN_NAME}/${DOMAIN_NAME}/g" /etc/nginx/nginx.conf

# self-signed cert (good enough for evaluation + local)
if [ ! -f /etc/nginx/ssl/server.crt ]; then
  openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/CN=${DOMAIN_NAME}"
fi

exec "$@"
