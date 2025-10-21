#!/bin/sh
# srcs/requirements/mariadb/tools/mariadb_conf.sh
set -e

echo "🔧 Configurando MariaDB..."

DATADIR="/var/lib/mysql"

# Configurar permisos
chown -R mysql:mysql "$DATADIR"
chmod 755 "$DATADIR"

# Si la BD no está inicializada -> inicializar
if [ ! -d "$DATADIR/mysql" ]; then
    echo "🚀 Inicializando base de datos por primera vez..."

    # Inicializar base de datos como usuario mysql
    su-exec mysql mysql_install_db --user=mysql --datadir="$DATADIR"

    # Arrancar servidor temporal
    echo "📝 Configurando usuarios iniciales..."
    su-exec mysql mysqld_safe --datadir="$DATADIR" --skip-networking &
    pid="$!"

    # Esperar a que MariaDB esté listo
    sleep 10

    # Configurar usuarios y base de datos
    mysql -uroot <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    echo "✅ Base de datos configurada correctamente"

    # Detener MariaDB temporal
    mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid" 2>/dev/null || true
fi

echo "🎯 Iniciando MariaDB..."
# Ejecutar como usuario mysql
exec su-exec mysql mysqld --datadir="$DATADIR"
