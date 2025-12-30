*This project has been created as part of the 42 curriculum by glevin.*

## Description
Small self-hosted stack deployed with Docker Compose: NGINX (TLS-only) fronts a PHP-FPM WordPress backed by MariaDB, with bind-mounted volumes for data persistence and a private bridge network for intra-service traffic.

## Instructions
- Prereqs: Docker + Docker Compose, a `/home/glevin/data` directory with subfolders `mariadb` and `wordpress`, and host DNS (e.g., `/etc/hosts`) pointing `glevin.42.fr` to your local IP.
- Secrets: create `srcs/secrets/db_root_password.txt`, `db_password.txt`, `wp_admin_password.txt`, and `wp_user_password.txt` with one value per file. These files are git-ignored and mounted as Docker secrets.
- Env: copy `srcs/.env.example` to `srcs/.env`, fill non-secret values (login, domain, usernames, DB name, emails). Passwords can stay empty if provided via secrets.
- Build/Run: `make` to build and start; `make down` to stop; `make clean` to prune dangling Docker data.
- Access: browse `https://glevin.42.fr` (self-signed cert); WordPress admin at `/wp-admin/` with the admin credentials you supplied.

## Resources
- References: Docker docs (images, volumes, networks), Docker Compose v2, NGINX TLS config, MariaDB secure installation, WordPress + WP-CLI setup, 42 Inception subject.
- AI usage: used for summarizing the subject requirements and drafting documentation; all configuration and scripts were reviewed and adjusted manually.

## Project description
- Infrastructure: three custom-built Debian-based images (NGINX, WordPress+php-fpm, MariaDB), single bridge network, NGINX as sole 443 entrypoint, TLSv1.2/1.3 enforced, bind-mounted volumes under `/home/glevin/data`.
- Main design choices: self-built images to avoid prebuilt pulls, Docker secrets for credentials, WP-CLI bootstrap for deterministic installs, and self-signed TLS for local use.
- Virtual Machines vs Docker: VMs virtualize hardware with full OS per guest (heavier, slower spin-up); Docker containers share the host kernel with isolated processes (lighter, faster, better for service composition).
- Secrets vs Environment Variables: secrets mount values from files with limited scope and reduced exposure in process lists/history; environment variables are convenient for non-sensitive config but can leak via inspect/logs.
- Docker Network vs Host Network: a user-defined bridge keeps service traffic isolated and easily addressable by service name; host networking shares the host stack, breaking isolation and violating the project rule.
- Docker Volumes vs Bind Mounts: volumes are managed by Docker and portable; bind mounts point to explicit host paths (used here) for transparent persistence and easy inspection/backups.
