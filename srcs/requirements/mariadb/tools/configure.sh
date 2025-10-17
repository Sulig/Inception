#!/bin/sh
set -e

# Verificar si es la primera ejecución
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando base de datos MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Iniciar MariaDB temporalmente para configurar
    echo "Configurando base de datos inicial..."
    mysqld_safe --datadir=/var/lib/mysql &
    MYSQL_PID=$!

    # Esperar a que MariaDB esté listo
    sleep 10

    # Configurar usuarios y base de datos
    mysql -e "DELETE FROM mysql.user WHERE User='';"
    mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -e "DROP DATABASE IF EXISTS test;"
    mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

    # Crear base de datos y usuario de WordPress
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -e "FLUSH PRIVILEGES;"

    # Detener MariaDB temporal
    kill $MYSQL_PID
    wait $MYSQL_PID
    sleep 5
fi

echo "Iniciando MariaDB definitivamente..."
exec mysqld_safe --datadir=/var/lib/mysql
