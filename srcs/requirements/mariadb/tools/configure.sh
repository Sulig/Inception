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
chown -R mysql:mysql "$DATADIR"

# Initialize DB if needed
if [ ! -d "$DATADIR/mysql" ]; then
  echo "=> Inicializando datos de MariaDB..."
  # mysql_install_db suele existir en mariadb-server; en algunas distros usar mariadb-install-db o mysqld --initialize
  if command -v mysql_install_db >/dev/null 2>&1; then
    mysql_install_db --user=mysql --datadir="$DATADIR"
  else
    echo "!! mysql_install_db no encontrado, intentando alternativa mysqld --initialize-insecure"
    mysqld --initialize-insecure --user=mysql --datadir="$DATADIR"
  fi
fi

# Start temporary server
echo "=> Arrancando servidor temporal..."
mysqld_safe --datadir="$DATADIR" &
pid="$!"

# Wait for server to be reachable over TCP
echo "=> Esperando a que MariaDB acepte conexiones (timeout 60s)..."
timeout=60
until mysqladmin ping --silent --protocol=TCP; do
  sleep 1
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "¡¡No arranca MariaDB temporal!!"
    # print logs for debugging
    tail -n 200 /var/log/mysql/error.log || true
    exit 1
  fi
done

# Configure root, database and user (idempotent)
echo "=> Configurando root y base de datos..."
mysql <<-EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

# Stop temporary server cleanly
echo "=> Deteniendo servidor temporal..."
if command -v mysqladmin >/dev/null 2>&1; then
  mysqladmin --protocol=TCP shutdown || kill "$pid"
else
  kill "$pid"
fi

wait "$pid" 2>/dev/null || true

# Replace process with final server; respect CMD by exec "$@"
echo "=> Arrancando servidor final de MariaDB (exec)..."
exec "$@"
