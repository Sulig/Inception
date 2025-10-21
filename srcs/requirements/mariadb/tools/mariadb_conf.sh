#!/bin/sh
# srcs/requirements/mariadb/tools/mariadb_conf.sh
set -e

echo "🔧 Configurando MariaDB..."

# Crear directorios necesarios
mkdir -p /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Inicializar si es necesario
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🚀 Inicializando base de datos..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Configuración inicial
    echo "📝 Iniciando servidor temporal..."
    mysqld_safe --skip-grant-tables --socket=/run/mysqld/mysqld.sock &
    pid="$!"
    sleep 15

    echo "👤 Configurando usuarios y permisos..."
    # Comandos actualizados para MariaDB 10.11
    mysql -S /run/mysqld/mysqld.sock -uroot <<-EOSQL
        FLUSH PRIVILEGES;
        -- Configurar password root
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

        -- Crear base de datos y usuario para WordPress
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

        FLUSH PRIVILEGES;
EOSQL

    echo "✅ Base de datos configurada correctamente"

    # Detener servidor temporal
    mysqladmin -S /run/mysqld/mysqld.sock -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid" 2>/dev/null || true
    sleep 5
fi

echo "🎯 Iniciando MariaDB..."
# Iniciar MariaDB forzando puerto 3306 y bind address
exec mysqld --defaults-file=/etc/mysql/my.cnf
