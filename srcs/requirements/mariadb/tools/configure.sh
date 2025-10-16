#!/bin/sh

set -e

# Inicializar base de datos si no existe
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Crear archivo SQL temporal para configuración inicial
    cat > /tmp/init.sql << EOF
DELETE FROM mysql.user WHERE user='';
DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

    # Ejecutar configuración inicial
    mysqld --user=mysql --bootstrap < /tmp/init.sql
    rm -f /tmp/init.sql
fi

# Crear directorio de logs
mkdir -p /var/log/mysql
chown mysql:mysql /var/log/mysql

echo "Starting MariaDB..."
exec mysqld --user=mysql --console
