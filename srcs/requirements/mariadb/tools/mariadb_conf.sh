#!/bin/bash
set -eux

# Variables de entorno obligatorias:
#   MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD

# 1) Preparar directorio de datos
DATADIR=/var/lib/mysql
chown -R mysql:mysql "$DATADIR"

# 2) Inicializar datos solo si NO existen
if [ ! -d "$DATADIR/mysql" ]; then
    echo "=> Inicializando datos de MariaDB por primera vez..."
    mysql_install_db --user=mysql --datadir="$DATADIR"

    # 3) Arrancar servidor temporal en background
    echo "=> Arrancando servidor temporal..."
    mysqld_safe --datadir="$DATADIR" &
    pid="$!"

    # 4) Esperar hasta que acepte conexiones
    echo "=> Esperando a que MariaDB esté lista..."
    timeout=30
    while ! mysqladmin ping --silent --protocol=TCP; do
        sleep 1
        timeout=$((timeout - 1))
        if [ $timeout -le 0 ]; then
            echo "¡¡No arranca MariaDB temporal!!"
            exit 1
        fi
    done

    # 5) Configurar contraseñas y usuarios (LOCAL + REMOTO)
    echo "=> Configurando root y base de datos..."
    mysql <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

        -- Crear base de datos
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

        -- Crear usuario para conexiones LOCALES
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';

        -- Crear usuario para conexiones REMOTAS (desde cualquier host)
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

        -- Dar privilegios a ambos usuarios
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

        FLUSH PRIVILEGES;
EOSQL

    # 6) Parar servidor temporal
    echo "=> Deteniendo servidor temporal..."
    kill "$pid"
    wait "$pid"

    echo "✅ Configuración inicial completada"
else
    echo "✅ Base de datos ya existe, asegurando que el usuario remoto existe..."

    # Arrancar temporalmente para crear usuario remoto si falta
    mysqld_safe --datadir="$DATADIR" &
    pid="$!"

    # Esperar a que MariaDB esté lista
    timeout=30
    while ! mysqladmin ping --silent --protocol=TCP -uroot -p${MYSQL_ROOT_PASSWORD}; do
        sleep 1
        timeout=$((timeout - 1))
        if [ $timeout -le 0 ]; then
            echo "¡¡No arranca MariaDB temporal!!"
            exit 1
        fi
    done

    # Asegurar que existe el usuario remoto
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    # Parar servidor temporal
    kill "$pid"
    wait "$pid"
fi

# 7) Finalmente, arranca el demonio definitivo
echo "=> Arrancando servidor final de MariaDB..."
exec mysqld --user=mysql --datadir="$DATADIR"
