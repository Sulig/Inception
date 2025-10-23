#!/bin/sh
set -e

echo "-- Configuring WordPress..."

# Check if we can resolve the hostname 'mariadb'
echo "* Checking DNS resolution..."
if ping -c 1 mariadb &> /dev/null; then
    echo "✅ DNS resolves correctly"
else
    echo "❌ Cannot resolve 'mariadb'"
    echo "~~ Network information:"
    cat /etc/hosts
    exit 1
fi

# Wait for MariaDB to be ready with diagnostics
echo "⏳ Waiting for MariaDB..."
timeout=90
while ! mysql -h mariadb -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SELECT 1;" ${WORDPRESS_DB_NAME} 2>/dev/null; do
  sleep 3
  timeout=$((timeout - 3))
  if [ $timeout -le 0 ]; then
    echo "❌ Unable to connect to MariaDB after 90 seconds"

    # Additional diagnosis
    echo "~~ Connectivity Diagnostics:"
    echo "   - Testing TCP connection to mariadb:3306..."
    if nc -z mariadb 3306 &> /dev/null; then
        echo "   ✅ Port 3306 is open"
    else
        echo "   ❌ Unable to connect to port 3306"
    fi

    echo "   - Verifying credentials..."
    echo "     DB_HOST: mariadb"
    echo "     DB_USER: ${WORDPRESS_DB_USER}"
    echo "     DB_NAME: ${WORDPRESS_DB_NAME}"

    # Trying to connect without a specific database
    if mysql -h mariadb -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SELECT 1;" 2>/dev/null; then
        echo "   ✅ Can connect to the server, but not to the specific DB"
        echo "   ~~ Checking if the database exists..."
        if mysql -h mariadb -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SHOW DATABASES;" 2>/dev/null | grep -q "${WORDPRESS_DB_NAME}"; then
            echo "   ✅ The database exists"
        else
            echo "   ❌ The database does NOT exist"
        fi
    else
        echo "   ❌ Unable to connect to MariaDB server"
    fi

    # Continue anyway to see if WordPress can recover
    echo "** Continuing despite the error..."
    break
  fi
  echo "-* Waiting for connection to MariaDB... ($timeout seconds remaining)"
done

echo "✅ Connected to MariaDB"

# Continue with normal WordPress setup...
if ! /usr/local/bin/wp core is-installed --path=/var/www/html 2>/dev/null; then
    echo "📀 WordPress is not installed, proceeding with setup..."

    if [ ! -f "/var/www/html/wp-config.php" ]; then
        echo "-- Creating wp-config.php..."
        /usr/local/bin/wp config create \
            --dbname=${WORDPRESS_DB_NAME} \
            --dbuser=${WORDPRESS_DB_USER} \
            --dbpass=${WORDPRESS_DB_PASSWORD} \
            --dbhost=mariadb \
            --locale=en_US \
            --path=/var/www/html \
            --skip-check
    fi

    echo "🚀 Installing WordPress..."
    /usr/local/bin/wp core install \
        --url=https://${DOMAIN_NAME} \
        --title=${WORDPRESS_TITLE} \
        --admin_user=${WORDPRESS_ADMIN_USER} \
        --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
        --admin_email=${WORDPRESS_ADMIN_EMAIL} \
        --path=/var/www/html \
        --skip-email

    /usr/local/bin/wp language core install en_US --path=/var/www/html --activate
    echo "✅ WordPress installed and configured"
else
    echo "✅ WordPress is already installed, skipping configuration"
fi

chown -R nobody:nobody /var/www/html
chmod -R 755 /var/www/html

echo "🚀 Starting PHP-FPM..."
exec php-fpm83 -F
