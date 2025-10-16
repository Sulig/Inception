#!/bin/sh

set -e

# Inicializar base de datos si no existe
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Iniciar MariaDB temporalmente
    mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    MYSQL_PID=$!

    # Esperar que MariaDB esté listo
    sleep 10

    # Configuración completa
    cat > /tmp/init.sql << EOF
DELETE FROM mysql.user WHERE user='';
DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Crear base de datos WordPress
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

-- Crear usuario WordPress
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Configurar root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

    # Ejecutar configuración
    mysql -uroot -S /run/mysqld/mysqld.sock < /tmp/init.sql
    rm -f /tmp/init.sql

    # Detener MariaDB temporal
    kill -TERM $MYSQL_PID
    wait $MYSQL_PID

    echo "Database '${MYSQL_DATABASE}' and user '${MYSQL_USER}' created successfully"
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --console
