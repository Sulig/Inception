#!/bin/bash
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
    echo "** Continuing despite the error..."
    break
  fi
  echo "-* Waiting for connection to MariaDB... ($timeout seconds remaining)"
done

echo "✅ Connected to MariaDB"

# Switch to wpuser for WordPress operations
echo "🔐 Switching to wpuser for WordPress operations..."

# Continue with normal WordPress setup...
if ! sudo -u wpuser /usr/local/bin/wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
    echo "📀 WordPress is not installed, proceeding with setup..."

    if [ ! -f "/var/www/html/wp-config.php" ]; then
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
    fi

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

    sudo -u wpuser /usr/local/bin/wp language core install en_US --path=/var/www/html --activate --allow-root
    echo "✅ WordPress installed and configured"
else
    echo "✅ WordPress is already installed, skipping configuration"
fi

# Create second user (editor) if it doesn't exist - CORREGIDO
echo "👤 Creating second user with editor role..."
set +e  # Temporarily disable error exit
sudo -u wpuser /usr/local/bin/wp user get ${WORDPRESS_USER} --field=id --path=/var/www/html --allow-root >/dev/null 2>&1
USER_EXISTS=$?
set -e  # Re-enable error exit

if [ $USER_EXISTS -eq 0 ]; then
    echo "✅ Second user '${WORDPRESS_USER}' already exists"
else
    sudo -u wpuser /usr/local/bin/wp user create ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} \
        --user_pass="${WORDPRESS_USER_PASSWORD}" \
        --role=editor \
        --display_name="Content Editor" \
        --path=/var/www/html \
        --allow-root
    echo "✅ Second user '${WORDPRESS_USER}' created with editor role"
fi

# Verify both users exist
echo "📋 Verifying WordPress users:"
sudo -u wpuser /usr/local/bin/wp user list --path=/var/www/html --allow-root

# Fix permissions (as root)
chown -R wpuser:wpuser /var/www/html
chmod -R 755 /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Ensure PHP-FPM directories have proper permissions
mkdir -p /var/run/php
chown -R wpuser:wpuser /var/run/php
chmod 755 /var/run/php

echo "🚀 Starting PHP-FPM..."
# Start PHP-FPM as root - it will handle user switching internally
exec php-fpm7.4 -F
