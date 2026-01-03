# User Guide

## Overview
This stack runs WordPress behind NGINX with HTTPS only (443) and MariaDB for persistence. All data is stored on the host under `/home/${LOGIN}/data`.

## Start / Stop
- Start: `make up`
- Stop: `make down`
- Rebuild and restart cleanly: `make re`
- Logs (follow): `make logs`
- Status: `make ps`

## Access
- Site: `https://${DOMAIN_NAME}` (accept the self-signed certificate warning).
- Admin dashboard: `https://${DOMAIN_NAME}/wp-admin`
  - Admin username is set in `srcs/.env` (`WP_ADMIN_USER`); password is the first line of `secrets/credentials.txt`.
- Only HTTPS is reachable.

## Credentials Management
- Secrets are mounted from files:
  - `secrets/db_root_password.txt`
  - `secrets/db_password.txt`
  - `secrets/credentials.txt` (line 1: admin password, line 2: regular user password)
- To rotate a credential: update the file, then `make up` (or `make re` if you need to rebuild) to restart containers with the new secrets.

## Basic Checks
- `make ps` shows `nginx`, `wordpress`, `mariadb` as Up.
- `curl -k https://${DOMAIN_NAME}` returns the WordPress site.
- `docker volume ls` shows the WordPress and MariaDB volumes; `docker volume inspect` paths point to `/home/${LOGIN}/data/...`.
- Add a test comment on the site and verify it appears and persists across restarts.
- TLS check: open `https://${DOMAIN_NAME}` in a browser and view the lock/connection details (should show TLS 1.2 or 1.3; self-signed warning is expected).
- Verify comments in DB (from host):
  ```sh
  sudo docker exec mariadb sh -c \
    'mariadb -u"$MYSQL_USER" -p"$(cat /run/secrets/db_password)" "$MYSQL_DATABASE" \
      -e "SELECT comment_ID, comment_post_ID, comment_author, comment_date, comment_approved FROM wp_comments;"'
  ```
- View all comments via WP-CLI (inside the WP container)
  ```sh
  sudo docker exec wordpress wp comment list --status=all --allow-root
  ```