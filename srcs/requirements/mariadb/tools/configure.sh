#!/bin/bash
set -eu

[ "${DEBUG:-}" = "1" ] && set -x

echo "=== Starting MariaDB configuration ==="
echo "Script location: $(pwd)"
echo "Script path: $0"

: "${MYSQL_ROOT_PASSWORD:?Need MYSQL_ROOT_PASSWORD non-empty}"
: "${MYSQL_DATABASE:?Need MYSQL_DATABASE non-empty}"
: "${MYSQL_USER:?Need MYSQL_USER non-empty}"
: "${MYSQL_PASSWORD:?Need MYSQL_PASSWORD non-empty}"

DATADIR=/var/lib/mysql
SOCKET="/var/run/mysqld/mysqld.sock"

echo "=== Setting up directories and permissions ==="
chown -R mysql:mysql "$DATADIR"
chown -R mysql:mysql /var/run/mysqld

# Initialize DB if needed
if [ ! -d "$DATADIR/mysql" ]; then
  echo "=> Initializing MariaDB data directory..."
  mysql_install_db --user=mysql --datadir="$DATADIR"
  echo "=> Initialization completed"
fi

# Start temporary server
echo "=> Starting temporary server (socket only)..."
mysqld --user=mysql --datadir="$DATADIR" --skip-networking --socket="$SOCKET" &
pid="$!"

# Wait for server to be ready
echo "=> Waiting for MariaDB to be ready..."
timeout=30
while true; do
  if [ -S "$SOCKET" ] && mysql -S "$SOCKET" -u root -e "SELECT 1" >/dev/null 2>&1; then
    echo "=> MariaDB is ready"
    break
  fi
  sleep 1
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "!! MariaDB not ready for connections !!"
    exit 1
  fi
done

# Configure database and users
echo "=> Configuring root and database..."
mysql -S "$SOCKET" -u root <<-EOSQL
  UPDATE mysql.user SET Password=PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User='root';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
  CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
  GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
  FLUSH PRIVILEGES;
EOSQL

echo "=> Configuration completed"

# Stop temporary server
echo "=> Stopping temporary server..."
kill "$pid"
wait "$pid" 2>/dev/null || true

# Start final server
echo "=> Starting final MariaDB server..."
exec "$@"
