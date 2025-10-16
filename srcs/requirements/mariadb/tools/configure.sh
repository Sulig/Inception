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

    # Esperar que MariaDB esté listo (más robusto)
    for i in {30..0}; do
        if mysql -uroot -S /run/mysqld/mysqld.sock -e "SELECT 1" > /dev/null 2>&1; then
            break
        fi
        echo "Waiting for MariaDB to start..."
        sleep 1
    done

    if [ "$i" = 0 ]; then
        echo "MariaDB failed to start!" >&2
        exit 1
    fi

    # Configurar base de datos y usuarios
    mysql -uroot -S /run/mysqld/mysqld.sock << EOF
DELETE FROM mysql.user WHERE user='';
DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # Detener MariaDB temporal
    kill -TERM "$PID"
    wait "$PID"

    echo "Database '${MYSQL_DATABASE}' and user '${MYSQL_USER}' created successfully"
fi

echo "Starting MariaDB server..."
exec mysqld --user=mysql --console
