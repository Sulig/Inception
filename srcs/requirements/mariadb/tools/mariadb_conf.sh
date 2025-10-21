#!/bin/sh
# srcs/requirements/mariadb/tools/mariadb_conf.sh
set -e

echo "🔧 Configurando MariaDB..."

# Crear directorios necesarios
mkdir -p /run/mysqld
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /run/mysqld

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
        -- Configurar password root (método compatible con MariaDB 10.11)
        UPDATE mysql.user SET authentication_string = PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User='root';
        UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User='root';

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
# Crear archivo de configuración para forzar puerto 3306
mkdir -p /etc/my.cnf.d
cat > /etc/my.cnf.d/server.cnf << EOF
[mysqld]
port=3306
bind-address=0.0.0.0
socket=/run/mysqld/mysqld.sock

[client]
port=3306
socket=/run/mysqld/mysqld.sock
EOF

# Iniciar MariaDB
exec mysqld --user=mysql
