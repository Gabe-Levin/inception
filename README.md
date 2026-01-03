*This project has been created as part of the 42 curriculum by glevin*

# Inception

## Description
- Docker Compose stack providing WordPress (php-fpm), MariaDB, and NGINX with HTTPS termination on port 443 only.
- Each service is built from a custom Dockerfile; data is persisted to host-bound volumes under `/home/${LOGIN}/data`.
- Self-signed TLS certificate is generated automatically; WordPress is preconfigured and should not show the install page.

## Instructions
- Configure `srcs/.env` (LOGIN, DOMAIN_NAME, HTTPS_PORT if not 443, DB and WP variables).
- Create secrets:
  - `secrets/db_root_password.txt`
  - `secrets/db_password.txt`
  - `secrets/credentials.txt` (line 1: WP admin password, line 2: regular user password)
- Build and run: `make build` then `make up`; stop with `make down`; rebuild with `make re`.
- Access: `https://${DOMAIN_NAME}` (self-signed cert warning is expected); admin at `/wp-admin` using creds from `.env` and `secrets/credentials.txt`.

## Resources
- Docker: https://docs.docker.com/ and Compose: https://docs.docker.com/compose/
- NGINX (TLS, templating): https://nginx.org/en/docs/ and https://docs.nginx.com/nginx/admin-guide/security-controls/terminating-ssl-http/
- WordPress (install, wp-cli): https://wordpress.org/support/article/wordpress-installation/ and https://developer.wordpress.org/cli/commands/
- MariaDB (server config, securing install): https://mariadb.com/kb/en/documentation/
- OpenSSL reference for self-signed certs: https://www.openssl.org/docs/manmaster/man1/openssl-req.html
- Project subject: `en.subject.pdf`
- AI usage: Drafted README outline and doc sections; suggested Dockerfile scaffolding, entrypoint flow, and compose wiring; provided troubleshooting ideas for bind mounts, permissions, TLS self-signed cert generation, wp-cli bootstrap, and VM config.
