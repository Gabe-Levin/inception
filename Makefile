LOGIN ?= $(shell whoami)
COMPOSE_FILE := srcs/docker-compose.yml
ENV_FILE := srcs/.env

DATA_DIR ?= /home/$(LOGIN)/data
DOCKER_CONFIG ?= $(DATA_DIR)/.docker

DOCKER_ENV = DOCKER_CONFIG=$(DOCKER_CONFIG) LOGIN=$(LOGIN) DATA_DIR=$(DATA_DIR)
COMPOSE = $(DOCKER_ENV) docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

.PHONY: build up down restart logs clean clean_full dirs

build: dirs
	$(COMPOSE) build

up: dirs
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

re: down clean up

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down --volumes --rmi all
	$(DOCKER_ENV) docker system prune -f

nuke:
	$(COMPOSE) down --volumes --rmi all
	$(DOCKER_ENV) docker volume prune -f
	$(DOCKER_ENV) docker network prune -f
	$(DOCKER_ENV) docker image prune -af
	$(DOCKER_ENV) docker container prune -f
	$(DOCKER_ENV) docker system prune -af
	rm -rf $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

dirs:
	mkdir -p $(DOCKER_CONFIG)
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress
