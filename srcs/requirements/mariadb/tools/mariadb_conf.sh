#!/bin/bash
# srcs/requirements/mariadb/tools/mariadb_conf.sh
set -e

DATADIR="/var/lib/mysql"

# Si la BD no está inicializada -> inicializar
if [ ! -d "$DATADIR/mysql" ]; then
    echo "[entrypoint] Inicializando base de datos..."

    # Inicializar base de datos
    mysql_install_db --user=mysql --datadir="$DATADIR" > /dev/null

    # Arrancar servidor temporal
    mysqld_safe --datadir="$DATADIR" --skip-networking &
    pid="$!"

    # Esperar a que MariaDB esté listo
    sleep 10

    echo "[entrypoint] Creando usuarios y base de datos iniciales..."

    # Usar variables de entorno
    : "${MYSQL_ROOT_PASSWORD:=rootpass}"
    : "${MYSQL_DATABASE:=wordpress}"
    : "${MYSQL_USER:=wp_user}"
    : "${MYSQL_PASSWORD:=wp_pass}"

    mysql -uroot <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    echo "[entrypoint] Deteniendo servidor temporal..."
    mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid" 2>/dev/null || true
    echo "[entrypoint] Inicialización completada."
fi

# Ejecutar el comando principal
exec "$@"
