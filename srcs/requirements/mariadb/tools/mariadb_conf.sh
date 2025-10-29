#!/bin/bash
set -eu

# 1) Prepare data directory
DATADIR=/var/lib/mysql
chown -R mysql:mysql "$DATADIR"

# 2) Initialize data only if it doesn't exist
if [ ! -d "$DATADIR/mysql" ]; then
    echo "=> Initializing MariaDB data for the first time..."
    mysql_install_db --user=mysql --datadir="$DATADIR"

    # 3) Start temporary server in the background
    echo "=> Starting temporary server..."
    mysqld_safe --datadir="$DATADIR" &
    pid="$!"

    # 4) Wait until it accepts connections
    echo "=> Waiting for MariaDB to be ready..."
    timeout=30
    while ! mysqladmin ping --silent --protocol=TCP; do
        sleep 1
        timeout=$((timeout - 1))
        if [ $timeout -le 0 ]; then
            echo "Temporal MariaDB not starting!!"
            exit 1
        fi
    done

    # 5) Configure passwords and users (LOCAL + REMOTE)
    echo "=> Configuring root and database..."
    mysql <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

        -- Create user for LOCAL connections
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';

        -- Create user for REMOTE connections (from any host)
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

        -- Give privileges to both users
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

        FLUSH PRIVILEGES;
EOSQL

    # 6) Stop server temporarily
    echo "=> Stopping server temporarily..."
    kill "$pid"
    wait "$pid"

    echo "✅ Initial setup complete"
else
    echo "✅ Database already exists, ensuring that the remote user exists..."

    # Temporarily boot to create remote user if missing
    mysqld_safe --datadir="$DATADIR" &
    pid="$!"

    # Wait for MariaDB to be ready
    timeout=30
    while ! mysqladmin ping --silent --protocol=TCP -uroot -p${MYSQL_ROOT_PASSWORD}; do
        sleep 1
        timeout=$((timeout - 1))
        if [ $timeout -le 0 ]; then
            echo "Temporal MariaDB not starting!!"
            exit 1
        fi
    done

    # Ensure that the remote user exists
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    # Stop server temporarily
    kill "$pid"
    wait "$pid"
fi

# 7) Finally, the ultimate demon starts
echo "=> Starting final MariaDB server..."
exec mysqld --user=mysql --datadir="$DATADIR"
