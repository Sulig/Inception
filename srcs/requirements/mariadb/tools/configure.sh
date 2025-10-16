#!/bin/sh

set -e

# Asegurar permisos en directorios críticos
mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql
chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql
chmod 755 /var/lib/mysql
chmod 755 /run/mysqld

# Inicializar base de datos si no existe
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Configuración inicial de seguridad
    cat > /tmp/init.sql << EOF
DELETE FROM mysql.user WHERE user='';
DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # Ejecutar configuración inicial
    mysqld --user=mysql --bootstrap --skip-networking < /tmp/init.sql
    rm -f /tmp/init.sql
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --console
