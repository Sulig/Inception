# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: sadoming <sadoming@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/10/14 17:25:36 by sadoming          #+#    #+#              #
#    Updated: 2025/10/16 19:10:32 by sadoming         ###   ########.fr        #
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
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/nginx
	@mkdir -p $(DATA_PATH)/nginx/{certs,conf}
	@echo "$(G)✓ Dirs created$(DEF)"
	@if [ ! -f ./srcs/.env ]; then \
		echo "$(Y)⚠ Creating .env using the template$(DEF)"; \
		cp ./srcs/.env.example ./srcs/.env 2>/dev/null || echo "$(R)✗ Template '.env.example' not found!$(DEF)"; \
	fi

# Building Comands:
build:
	@echo "$(B)=== Building Docker imgs ===$(RESET)"
	@cd srcs && $(COMPOSE) build
	@echo "$(G)✓ Builded correctly!$(RESET)"

up:
	@echo "$(B)=== Starting services ===$(RESET)"
	@cd srcs && $(COMPOSE) up -d
	@echo "$(G)✓ Services started!$(RESET)"

up-debug:
	@cd srcs && $(COMPOSE) up

down:
	@echo "$(Y)=== Stoping services ===$(RESET)"
	@cd srcs && $(COMPOSE) down
	@echo "$(G)✓ Services stoped$(RESET)"

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
# Other Comands:
ps:
	@cd srcs && $(COMPOSE) ps

status:
	@echo "$(B)=== Service Status ===$(RESET)"
	@cd srcs && $(COMPOSE) ps
	@echo ""
	@echo "$(B)=== Volumes ===$(RESET)"
	@docker volume ls | grep srcs_ || echo "No volumes!"
	@echo ""
	@echo "$(B)=== Network ===$(RESET)"
	@docker network ls | grep srcs_ || echo "No network!"

check:
	@echo "$(B)=== Checking config ===$(RESET)"
	@cd srcs && $(COMPOSE) config
# ********************************************************************************* #
# Clean region
clean: down
	@echo "$(Y)=== Cleaning containers ===$(RESET)"
	@docker rm -f $(shell docker ps -aq) 2>/dev/null || true
	@echo "$(G)✓ Containers cleaned$(RESET)"

# Limpiar contenederos e imágenes
fclean: clean
	@echo "$(Y)=== Cleaning images ===$(RESET)"
	@docker rmi -f $(shell docker images -q) 2>/dev/null || true
	@echo "$(G)✓ Images cleaned$(RESET)"

clear: fclean
	@clear

reset: down fclean volclean
	@echo "$(G)✓ Successfull reset$(RESET)"
# -------------------- #
.PHONY: all setup build up up-debug down re reload logs status exec clean fclean volclean reset check help
# ********************************************************************************** #
