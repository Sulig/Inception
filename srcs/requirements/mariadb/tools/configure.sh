#!/bin/bash

service mysql start

if [ ! -d "/var/lib/mysql" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi


