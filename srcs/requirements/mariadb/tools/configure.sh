#!/bin/sh

set -e

echo "=== MARIADB SETUP ==="

if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Initializing database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Configuración mínima
    mysqld --user=mysql --bootstrap << EOF
CREATE DATABASE ${MYSQL_DATABASE};
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --console
