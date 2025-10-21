# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: sadoming <sadoming@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/10/14 17:25:36 by sadoming          #+#    #+#              #
#    Updated: 2025/10/21 12:09:29 by sadoming         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

USER	=	sadoming

COMPOSE			= docker-compose
COMPOSE_FILE	= ./srcs/docker-compose.yml
DOMAIN			= $(USER).42.fr
DATA_PATH		= /home/$(USER)/data

####################################################################
# ------------------ #
# Colors
DEF	:=	\033[0m

R	:=	\033[0;31m
G	:=	\033[0;32m
Y	:=	\033[0;33m
B	:=	\033[0;34m
P	:=	\033[0;35m
C	:=	\033[0;36m
W	:=	\033[0;37m

RG	:=	\033[1;32m
# ------------------ #
# ******************************************************************************* #
#-------------------------------------------------------------#
all: setup build up
	@echo "$(RG)\n~ **************************************** ~"
	@echo " ~\t\t All Ready!\t\t ~"
	@echo "~ **************************************** ~$(DEF)\n"
	@make -s author
#-------------------------------------------------------------#
author:
	@echo "$(P)~ **************************************** ~"
	@echo " ~\t      Made by Sadoming \t         ~"
	@echo "~ **************************************** ~$(DEF)\n"
#-------------------------------------------------------------#
#-------------------------------------------------------------#
help:
	@echo "\033[1;37m\n ~ Posible comands:\n"
	@echo "\t~ \t\t\t #-> Buid all the services\n"
	@echo "\t~ all  \t\t #-> Build all the services\n"
	@echo "\t~ build \t #-> Build all the services\n"
	@echo "\t~ up     \t\t #-> Activate all the services\n"
	@echo "\t~ down \t #-> Stop all the services\n"
	@echo "\t~ ps     \t\t #-> List all the services\n"
	@echo "\t~ clean \t #-> Clean all\n"
	@echo "\t~ clear \t #-> Clean all & clear\n"
	@echo "\t~ re   \t\t #-> Reboot all containers\n"
	@make -s author
#-------------------------------------------------------------#
# ******************************************************************************* #
setup:
	@echo "$(B)=== Configuring Inception ===$(DEF)"
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@chmod 755 $(DATA_PATH)
	@echo "$(G)✓ Dirs created$(DEF)"
	@if [ ! -f ./srcs/.env ]; then \
		echo "$(Y)⚠ Creating .env using the template$(DEF)"; \
		cp ./srcs/.env.template ./srcs/.env 2>/dev/null || echo "$(R)✗ Template '.env.template' not found!$(DEF)"; \
	fi

# Building Comands:
build:
	@echo "$(B)=== Building Docker imgs ===$(DEF)"
	@cd srcs && $(COMPOSE) build
	@echo "$(G)✓ Builded correctly!$(DEF)"

up:
	@echo "$(B)=== Starting services ===$(DEF)"
	@cd srcs && $(COMPOSE) up -d
	@echo "$(G)✓ Services started!$(DEF)"

up-debug:
	@cd srcs && $(COMPOSE) up

down:
	@echo "$(Y)=== Stoping services ===$(DEF)"
	@cd srcs && $(COMPOSE) down
	@echo "$(G)✓ Services stoped$(DEF)"

re: down up

reload:
	@cd srcs && $(COMPOSE) restart
#--------------------
# Specific service activating
mariadb: build
	@cd srcs && $(COMPOSE) up -d mariadb

wordpress: build
	@cd srcs && $(COMPOSE) up -d wordpress

nginx: build
	@cd srcs && $(COMPOSE) up -d nginx
#--------------------
# Status and Debug commands:
ps:
	@cd srcs && $(COMPOSE) ps

status:
	@echo "$(B)=== Service Status ===$(DEF)"
	@cd srcs && $(COMPOSE) ps
	@echo ""
	@echo "$(B)=== Volumes ===$(DEF)"
	@docker volume ls | grep srcs_ || echo "No volumes!"
	@echo ""
	@echo "$(B)=== Network ===$(DEF)"
	@docker network ls | grep srcs_ || echo "No network!"

check:
	@echo "$(B)=== Checking config ===$(DEF)"
	@cd srcs && $(COMPOSE) config

logs:
	@cd srcs && docker logs mariadb
	@cd srcs && docker logs wordpress
	@cd srcs && docker logs nginx
# ********************************************************************************* #
# Clean region
clean: down
	@echo "$(Y)=== Cleaning containers ===$(DEF)"
	@docker rm -f $(shell docker ps -aq) 2>/dev/null || true
	@echo "$(G)✓ Containers cleaned$(DEF)"

# Limpiar contenederos e imágenes
fclean: clean
	@echo "$(Y)=== Cleaning images ===$(DEF)"
	@docker rmi -f $(shell docker images -q) 2>/dev/null || true
	@sudo rm -rf $(DATA_PATH)
	@echo "$(G)✓ Images cleaned$(DEF)"

clear: fclean
	@clear

volclean: fclean
	@docker volume prune -f
	@docker builder prune
	@docker system prune -a

DEF: down fclean volclean
	@echo "$(G)✓ Successfull DEF$(DEF)"
# -------------------- #
.PHONY: all setup build up up-debug down re reload logs status exec clean fclean volclean DEF check help
# ********************************************************************************** #
