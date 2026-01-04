COMPOSE := docker compose -f srcs/docker-compose.yml --env-file srcs/.env

.PHONY: build up down restart logs clean clean_full dirs

build:
	$(COMPOSE) build --no-cache

up: dirs
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

re: down up

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down --volumes --rmi all
	docker system prune -f

nuke: clean
	docker volume prune -f
	docker network prune -f
	docker image prune -af
	docker container prune -f
	docker system prune -af
	rm -rf /home/$(USER)/data/mariadb /home/$(USER)/data/wordpress
	mkdir -p /home/$(USER)/data/mariadb /home/$(USER)/data/wordpress
