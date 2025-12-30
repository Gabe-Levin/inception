# Developer Documentation

## Setup from scratch
- Install Docker + Docker Compose v2.
- Create host directories: `/home/glevin/data/mariadb` and `/home/glevin/data/wordpress`.
- Copy `srcs/.env.example` to `srcs/.env`; fill login/domain/usernames/emails and other non-secret values.
- Add secrets (one line per file): `srcs/secrets/db_root_password.txt`, `db_password.txt`, `wp_admin_password.txt`, `wp_user_password.txt`.
- Optional: add `glevin.42.fr` to `/etc/hosts` pointing to `127.0.0.1` for local access.

## Build and launch
- Build + start: `make`
- Rebuild fresh: `make re`
- Stop: `make down`
- Full cleanup of unused Docker data: `make clean`

## Managing containers and volumes
- Status: `docker compose -f srcs/docker-compose.yml --env-file srcs/.env ps`
- Logs: `docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs -f`
- Exec into a container: `docker exec -it inception-mariadb-1 /bin/sh` (adjust name as needed).
- Volumes mount host paths directly, so file access/backup can be done on the host.

## Data locations and persistence
- MariaDB data: `/home/glevin/data/mariadb` on the host (mounted to `/var/lib/mysql`).
- WordPress files (core, plugins, uploads): `/home/glevin/data/wordpress` on the host (mounted to `/var/www/html`).
- Secrets: `srcs/secrets/*.txt` (git-ignored, mounted as Docker secrets).
