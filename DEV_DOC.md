# Developer Guide

## Prerequisites
- Docker with the Compose plugin
- GNU Make

## Setup
1) Copy `srcs/.env.example` to `srcs/.env`, then configure LOGIN, DOMAIN_NAME, HTTPS_PORT (if not 443), DB and WP variables.
2) Create secrets:
   - `secrets/db_root_password.txt`
   - `secrets/db_password.txt`
   - `secrets/credentials.txt` (line 1: WP admin password, line 2: regular user password)
3) Ensure data directories exist (or run `make up` to create): `/home/${LOGIN}/data/{mariadb,wordpress}`.

## Makefile Targets
- `make build` — build all service images
- `make up` — start stack in detached mode
- `make down` — stop stack
- `make re` — down + clean + up
- `make logs` — follow logs
- `make ps` — service status
- `make clean` — down + remove volumes/images for this project
- `make nuke` — full prune (images/networks/volumes)

## Docker Compose Commands
- Compose file: `srcs/docker-compose.yml`
- Start: `docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d`
- Stop: `docker compose -f srcs/docker-compose.yml --env-file srcs/.env down`
- Logs: `docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs -f`
- Status: `docker compose -f srcs/docker-compose.yml --env-file srcs/.env ps`

## Data Persistence
- Bind-mounted volumes map to `/home/${LOGIN}/data/mariadb` and `/home/${LOGIN}/data/wordpress`.
- Data persists across rebuilds and reboots; use `make nuke` to reset everything.
