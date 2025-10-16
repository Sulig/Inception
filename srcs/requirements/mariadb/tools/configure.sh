#!/bin/sh

set -e

echo "Starting MariaDB initialization..."

# Solo inicializar si el directorio está vacío
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Initializing fresh MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Iniciar MariaDB temporalmente para configuración
    mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    PID="$!"

    # Esperar que MariaDB esté listo
    sleep 10

    # Configurar base de datos y usuarios
    mysql -uroot -S /run/mysqld/mysqld.sock << EOF
DELETE FROM mysql.user WHERE user='';
DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # Detener MariaDB temporal
    kill -TERM "$PID"
    wait "$PID"
fi

echo "Starting MariaDB server..."
exec mysqld --user=mysql --console
