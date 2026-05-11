COMPOSE_FILE = srcs/docker-compose.yml
BONUS_COMPOSE_FILE = srcs/docker-compose.bonus.yml
DATA_DIR = /home/$(USER)/data

all: build up
BONUS = -f $(COMPOSE_FILE) -f $(BONUS_COMPOSE_FILE)


build:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb
	@docker compose -f $(COMPOSE_FILE) build

up:
	@docker compose -f $(COMPOSE_FILE) up -d

bonus:
	@docker compose -f $(COMPOSE_FILE) -f $(BONUS_COMPOSE_FILE) up --build -d

down:
	@docker compose -f $(COMPOSE_FILE) -f $(BONUS_COMPOSE_FILE) down

clean: down
	@docker compose -f $(COMPOSE_FILE) -f $(BONUS_COMPOSE_FILE) down --volumes --remove-orphans
	@docker system prune -af

fclean: clean
	@sudo rm -rf $(DATA_DIR)
	@docker volume prune -f

re: fclean all

logs:
	@docker compose -f $(COMPOSE_FILE) -f $(BONUS_COMPOSE_FILE) logs -f

status:
	@docker compose -f $(COMPOSE_FILE) -f $(BONUS_COMPOSE_FILE) ps

.PHONY: all build up bonus down clean fclean re logs status
