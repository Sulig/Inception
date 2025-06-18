# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: sadoming <sadoming@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/10/14 17:25:36 by sadoming          #+#    #+#              #
#    Updated: 2025/05/12 19:56:21 by sadoming         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #
# Change these based on your conf 

USER	:=	sadoming

####################################################################
# ------------------ #
# Colors
R	:=	\033[0;31m
G	:=	\033[0;32m
Y	:=	\033[0;33m
B	:=	\033[0;34m
P	:=	\033[0;35m
C	:=	\033[0;36m
W	:=	\033[0;37m
DEF	:=	\033[0m

RG	:=	\033[1;32m
# ------------------ #
# Flags:
COMPOSE			=	docker-compose -f srcs/docker-compose.yml
COMPOSE_DOWN_FLAGS	=	--volumes --remove-orphans
# ------------------ #
# Services:
MARIADB		:=	mariadb
WORDPRESS	:=	wordpress
#
# ------------------ #
# Directories:
#DATA_DIR	:=	/home/$(USER)/data/volumes/mariadb_data

# ******************************************************************************* #
#-------------------------------------------------------------#
all: build up
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
	@echo "\t~ clean \t #-> Clean all\n"
	@echo "\t~ clear \t #-> Clean all & clear\n"
	@echo "\t~ re   \t\t #-> Reboot all containers\n"
	@make -s author
#-------------------------------------------------------------#
# ******************************************************************************* #
# Building Comands:
build:
	@$(COMPOSE) build $(MARIADB)
	@$(COMPOSE) build $(WORDPRESS)

up:
	@$(COMPOSE) up -d $(MARIADB)
	@$(COMPOSE) up -d $(WORDPRESS)

down:
	@$(COMPOSE) down $(COMPOSE_DOWN_FLAGS)

re: down build up
#--------------------
# Other Comands:
logs:
	@(COMPOSE) logs -f $(MARIADB)
	@(COMPOSE) logs -f $(WORDPRESS)

ps:
	@$(COMPOSE) ps
# ********************************************************************************* #
# Clean region

clean:
	@$(COMPOSE) down -v --remove-orphans
	@echo "$(B)\n All cleaned succesfully$(DEF)\n"

clear: clean
	@clear
# -------------------- #
.PHONY: all author help clean clear re
.PHONY: build up down create-dirs logs ps
# ********************************************************************************** #
