#!/bin/sh
# srcs/requirements/mariadb/tools/configure.sh
set -e

echo "🔧 Configurando MariaDB..."

# Configurar permisos
chown -R mysql:mysql /var/lib/mysql

# Inicializar si es la primera vez
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🚀 Inicializando base de datos por primera vez..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Configuración mínima
    mysqld_safe --datadir=/var/lib/mysql &
    sleep 10

    # Crear base de datos y usuario
    mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -e "GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -e "FLUSH PRIVILEGES;"

    # Detener MariaDB temporal
    mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown
    sleep 5
fi

echo "🎯 Iniciando MariaDB..."
exec mysqld_safe --datadir=/var/lib/mysql
