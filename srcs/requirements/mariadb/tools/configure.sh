#!/bin/bash
set -eu

[ "${DEBUG:-}" = "1" ] && set -x

echo "=== Starting MariaDB configuration ==="
echo "Using Alpine Linux with MariaDB"

: "${MYSQL_ROOT_PASSWORD:?Need MYSQL_ROOT_PASSWORD non-empty}"
: "${MYSQL_DATABASE:?Need MYSQL_DATABASE non-empty}"
: "${MYSQL_USER:?Need MYSQL_USER non-empty}"
: "${MYSQL_PASSWORD:?Need MYSQL_PASSWORD non-empty}"

DATADIR=/var/lib/mysql
SOCKET="/var/run/mysqld/mysqld.sock"

echo "=== Setting up directories and permissions ==="
chown -R mysql:mysql "$DATADIR"
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/log/mysql

# Ensure the socket directory exists and has correct permissions
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

# Initialize DB if needed
if [ ! -d "$DATADIR/mysql" ]; then
  echo "=> Initializing MariaDB data directory..."
  # Use the appropriate installation command for Alpine
  mariadb-install-db --user=mysql --datadir="$DATADIR" --auth-root-authentication-method=normal
  echo "=> Initialization completed"
fi

# Start temporary server with more options for Alpine
echo "=> Starting temporary server..."
mysqld --user=mysql --datadir="$DATADIR" --skip-networking --socket="$SOCKET" --console &
pid="$!"

# Improved waiting mechanism for Alpine
echo "=> Waiting for MariaDB to be ready..."
timeout=60
for i in $(seq 1 $timeout); do
  if [ -S "$SOCKET" ]; then
    # Try to connect and execute a simple command
    if mysql -S "$SOCKET" -u root -e "SELECT 1" >/dev/null 2>&1; then
      echo "=> MariaDB is ready and accepting connections"
      break
    fi
  fi

  if [ $i -eq $timeout ]; then
    echo "!! ERROR: MariaDB not ready after $timeout seconds !!"
    echo "=== Process status ==="
    ps aux | grep mysql || true
    echo "=== Socket status ==="
    ls -la /var/run/mysqld/ || true
    echo "=== Error logs ==="
    tail -n 50 /var/log/mysql/error.log 2>/dev/null || echo "No error log available"
    exit 1
  fi

  sleep 1
  echo "    Still waiting... ($i/$timeout)"
done

# Configure database and users
echo "=> Configuring root and database..."
mysql -S "$SOCKET" -u root <<-EOSQL
  -- Set root password
  ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

  -- Remove anonymous users
  DELETE FROM mysql.user WHERE User='';

  -- Remove remote root users
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

  -- Remove test database
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

  -- Create application database and user
  CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
  CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
  GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
  FLUSH PRIVILEGES;
EOSQL

echo "=> Configuration completed successfully"

# Stop temporary server
echo "=> Stopping temporary server..."
kill "$pid" || true
wait "$pid" 2>/dev/null || true

# Start final server
echo "=> Starting final MariaDB server..."
exec "$@"
