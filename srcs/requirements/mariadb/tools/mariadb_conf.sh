#!/bin/sh
# srcs/requirements/mariadb/tools/mariadb_conf.sh (VERSIÓN ALTERNATIVA)
set -e

echo "🔧 Configurando MariaDB..."

# Crear directorios necesarios
mkdir -p /run/mysqld
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /run/mysqld

# Inicializar si es necesario
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🚀 Inicializando base de datos..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Configuración inicial
    mysqld_safe --skip-grant-tables &
    sleep 10

    mysql -uroot <<-EOSQL
        USE mysql;
        UPDATE user SET password=PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User='root';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    mysqladmin -uroot shutdown
    sleep 5
fi

echo "🎯 Iniciando MariaDB..."
# Forzar escucha en puerto 3306
exec mysqld --user=mysql --port=3306 --bind-address=0.0.0.0
