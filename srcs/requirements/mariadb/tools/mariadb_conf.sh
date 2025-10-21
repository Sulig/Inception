#!/bin/sh
# srcs/requirements/mariadb/tools/mariadb_conf.sh
set -e

echo "🔧 Configurando MariaDB..."

DATADIR="/var/lib/mysql"
SOCKETDIR="/run/mysqld"

# Asegurar que los directorios existen y tienen permisos correctos
mkdir -p "$SOCKETDIR"
chown -R mysql:mysql "$DATADIR"
chown -R mysql:mysql "$SOCKETDIR"
chmod 755 "$DATADIR"
chmod 755 "$SOCKETDIR"

# Si la BD no está inicializada -> inicializar
if [ ! -d "$DATADIR/mysql" ]; then
    echo "🚀 Inicializando base de datos por primera vez..."

    # Inicializar base de datos como usuario mysql
    su-exec mysql mysql_install_db --user=mysql --datadir="$DATADIR"

    # Arrancar servidor temporal
    echo "📝 Configurando usuarios iniciales..."
    su-exec mysql mysqld_safe --datadir="$DATADIR" --skip-networking --socket="$SOCKETDIR/mysqld.sock" &
    pid="$!"

    # Esperar a que MariaDB esté listo
    echo "⏳ Esperando a que MariaDB se inicie..."
    sleep 15

    # Configurar usuarios y base de datos
    mysql -uroot -S "$SOCKETDIR/mysqld.sock" <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    echo "✅ Base de datos configurada correctamente"

    # Detener MariaDB temporal
    mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" -S "$SOCKETDIR/mysqld.sock" shutdown
    wait "$pid" 2>/dev/null || true
    sleep 5
fi

echo "🎯 Iniciando MariaDB definitivamente..."
# Ejecutar como usuario mysql escuchando en red
exec su-exec mysql mysqld --datadir="$DATADIR" --socket="$SOCKETDIR/mysqld.sock" --port=3306 --bind-address=0.0.0.0
