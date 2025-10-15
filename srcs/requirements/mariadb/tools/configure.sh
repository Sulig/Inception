#!/bin/bash
set -eu

# Verbose only if DEBUG set
[ "${DEBUG:-}" = "1" ] && set -x

# Required env vars
: "${MYSQL_ROOT_PASSWORD:?Need MYSQL_ROOT_PASSWORD non-empty}"
: "${MYSQL_DATABASE:?Need MYSQL_DATABASE non-empty}"
: "${MYSQL_USER:?Need MYSQL_USER non-empty}"
: "${MYSQL_PASSWORD:?Need MYSQL_PASSWORD non-empty}"

DATADIR=/var/lib/mysql
SOCKET="/var/run/mysqld/mysqld.sock"

chown -R mysql:mysql "$DATADIR"

# Initialize DB if needed
if [ ! -d "$DATADIR/mysql" ]; then
  echo "=> Inicializando datos de MariaDB..."

  # Usar método de inicialización que asegura root sin contraseña
  if command -v mariadb-install-db >/dev/null 2>&1; then
    mariadb-install-db --user=mysql --datadir="$DATADIR" --auth-root-authentication-method=normal
  elif command -v mysql_install_db >/dev/null 2>&1; then
    mysql_install_db --user=mysql --datadir="$DATADIR"
  else
    mysqld --initialize-insecure --user=mysql --datadir="$DATADIR"
  fi
fi

# Start temporary server without networking restrictions
echo "=> Arrancando servidor temporal..."
mysqld_safe --datadir="$DATADIR" --skip-networking --socket="$SOCKET" &
pid="$!"

# Wait for socket to be available
echo "=> Esperando a que el socket de MariaDB esté listo..."
timeout=30
while [ ! -S "$SOCKET" ]; do
  sleep 1
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "¡¡Socket no creado!!"
    tail -n 200 /var/log/mysql/error.log || true
    exit 1
  fi
done

# Now configure using socket connection (no password needed for initial setup)
echo "=> Configurando root y base de datos..."
mysql -S "$SOCKET" <<-EOSQL
-- Asegurar que root puede conectarse y tiene todos los privilegios
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Crear base de datos y usuario para WordPress
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

# Stop temporary server
echo "=> Deteniendo servidor temporal..."
kill "$pid"
wait "$pid" 2>/dev/null || true

# Start final server
echo "=> Arrancando servidor final de MariaDB..."
exec "$@"
