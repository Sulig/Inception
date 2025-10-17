#!/bin/sh
set -e

# Verificar si es la primera ejecución
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando base de datos MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

echo "Iniciando MariaDB..."
exec mysqld_safe --datadir=/var/lib/mysql
