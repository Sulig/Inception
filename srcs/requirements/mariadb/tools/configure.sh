#!/bin/sh

set -e

echo "Starting MariaDB initialization..."

# Inicializar base de datos si no existe
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Initializing fresh MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Iniciar MariaDB temporalmente sin autenticación
    mysqld --user=mysql --skip-grant-tables --skip-networking &
    MYSQL_PID=$!

    # Esperar a que esté listo
    sleep 10

    # Configuración completa SIN CONTRASEÑAS inicialmente
    mysql -uroot << EOF
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE user='';
DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

-- Crear usuario WordPress
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Configurar root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

    # Detener MariaDB temporal
    kill -TERM $MYSQL_PID
    wait $MYSQL_PID

    echo "Database setup completed"
fi

echo "Starting MariaDB server..."
exec mysqld --user=mysql --console
