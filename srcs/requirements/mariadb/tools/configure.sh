#!/bin/sh
# srcs/requirements/mariadb/tools/configure.sh
set -e

echo "🔧 Configurando MariaDB..."

# Configurar permisos
chown -R mysql:mysql /var/lib/mysql

# Inicializar si es la primera vez
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🚀 Inicializando base de datos por primera vez..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Iniciar MariaDB temporalmente sin autenticación para configuración inicial
    echo "📝 Configurando usuarios iniciales..."
    mysqld_safe --skip-grant-tables --datadir=/var/lib/mysql &
    MYSQL_PID=$!
    sleep 10

    # Configurar root password y crear usuario de WordPress
    mysql -e "FLUSH PRIVILEGES;"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
    mysql -e "FLUSH PRIVILEGES;"

    echo "✅ Base de datos configurada correctamente"

    # Detener MariaDB temporal
    kill $MYSQL_PID
    wait $MYSQL_PID
    sleep 5
fi

echo "🎯 Iniciando MariaDB definitivamente..."
exec mysqld_safe --datadir=/var/lib/mysql
