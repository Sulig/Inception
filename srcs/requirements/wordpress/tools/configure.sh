#!/bin/bash
set -e

echo "-- Configuring WordPress..."

# Wait for MariaDB to be ready
echo "⏳ Waiting for MariaDB..."
timeout=90
while ! mysql -h mariadb -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SELECT 1;" ${WORDPRESS_DB_NAME} 2>/dev/null; do
  sleep 3
  timeout=$((timeout - 3))
  if [ $timeout -le 0 ]; then
    echo "❌ Unable to connect to MariaDB after 90 seconds"
    exit 1
  fi
  echo "Waiting for connection to MariaDB... ($timeout seconds remaining)"
done

echo "✅ Connected to MariaDB"

# Check if WordPress is already installed
if sudo -u wpuser /usr/local/bin/wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
    echo "✅ WordPress is already installed, skipping setup"
else
    echo "📀 WordPress is not installed, proceeding with setup..."

    # Create wp-config.php
    echo "-- Creating wp-config.php..."
    sudo -u wpuser /usr/local/bin/wp config create \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${WORDPRESS_DB_PASSWORD} \
        --dbhost=${WORDPRESS_DB_HOST} \
        --locale=en_US \
        --path=/var/www/html \
        --skip-check \
        --allow-root

    # Install WordPress
    echo "🚀 Installing WordPress..."
    sudo -u wpuser /usr/local/bin/wp core install \
        --url=https://${DOMAIN_NAME} \
        --title=${WORDPRESS_TITLE} \
        --admin_user=${WORDPRESS_ADMIN_USER} \
        --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
        --admin_email=${WORDPRESS_ADMIN_EMAIL} \
        --path=/var/www/html \
        --skip-email \
        --allow-root

    # Install language
    sudo -u wpuser /usr/local/bin/wp language core install en_US --path=/var/www/html --activate --allow-root

    # Create second user ONLY if it doesn't exist
    echo "👤 Checking second user..."
    if ! sudo -u wpuser /usr/local/bin/wp user get ${WORDPRESS_USER} --field=id --path=/var/www/html --allow-root 2>/dev/null; then
        echo "Creating second user '${WORDPRESS_USER}'..."
        sudo -u wpuser /usr/local/bin/wp user create ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} \
            --user_pass="${WORDPRESS_USER_PASSWORD}" \
            --role=editor \
            --display_name="Content Editor" \
            --path=/var/www/html \
            --allow-root
        echo "✅ Second user created"
    else
        echo "✅ Second user already exists"
    fi

    echo "✅ WordPress setup complete"
fi

# Fix permissions
echo "🔧 Setting permissions..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Ensure PHP-FPM directories
mkdir -p /var/run/php
chown -R www-data:www-data /var/run/php

echo "🚀 Starting PHP-FPM..."
exec php-fpm7.4 -F
