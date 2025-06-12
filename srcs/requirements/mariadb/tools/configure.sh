#!/bin/bash

set -e

# Configurar directorio de datos
DATA_DIR="/var/lib/mysql"
mkdir -p ${DATA_DIR}
chown -R mysql:mysql ${DATA_DIR}
chmod 755 ${DATA_DIR}

# Leer secrets desde archivos
MYSQL_ROOT_PASSWORD=$(cat ${MYSQL_ROOT_PASSWORD_FILE})
MYSQL_PASSWORD=$(cat ${MYSQL_PASSWORD_FILE})
MYSQL_DATABASE=${MYSQL_DATABASE}
MYSQL_USER=${MYSQL_USER}

# Inicializar DB si es necesario
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql
fi

# Arrancar MariaDB temporalmente
echo "Starting temporary MariaDB instance..."
mysqld_safe --skip-networking --socket=/var/run/mysqld/mysqld.sock &
MYSQL_PID=$!

# Esperar inicio
echo "Waiting for MariaDB to start..."
sleep 5
while ! mysqladmin ping --silent; do
    sleep 1
done

# Configurar root y usuario
echo "Configuring users and database..."
mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Detener instancia temporal
echo "Stopping temporary instance..."
kill -TERM ${MYSQL_PID}
wait ${MYSQL_PID}

# Ejecutar MariaDB en primer plano
echo "Starting final MariaDB instance..."
exec mysqld --user=mysql
