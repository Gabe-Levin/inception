NAME=inception
ENV_FILE=srcs/.env

$(ENV_FILE):
	@echo "Missing $(ENV_FILE). Copy srcs/.env.example and fill secrets + paths." && exit 1

all: $(ENV_FILE)
	docker compose -f srcs/docker-compose.yml --env-file $(ENV_FILE) up -d --build

down:
	docker compose -f srcs/docker-compose.yml --env-file $(ENV_FILE) down -v

clean: down
	docker system prune -af

re: clean all

.PHONY: all down clean re
