# User Documentation

## Services provided
- NGINX serving HTTPS on `https://glevin.42.fr`, proxying PHP requests to WordPress (php-fpm).
- WordPress CMS with one admin user and one regular user.
- MariaDB storing WordPress data.

## Start and stop
- Ensure `srcs/.env` exists and secrets files are populated (see README).
- Start: `make`
- Stop: `make down`

## Access
- Site: `https://glevin.42.fr` (accept the self-signed certificate).
- Admin: `https://glevin.42.fr/wp-admin/` using the admin credentials you placed in `srcs/secrets/wp_admin_password.txt` (username from `.env`).

## Credentials location
- Stored locally as Docker secrets: `srcs/secrets/db_root_password.txt`, `db_password.txt`, `wp_admin_password.txt`, `wp_user_password.txt`.
- Usernames and non-sensitive settings live in `srcs/.env`.

## Health checks
- Containers running: `docker ps --filter name=inception`
- Logs: `docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs -f`
- WordPress responds: open the site/admin URL; PHP errors will appear in the NGINX logs.
