#!/bin/sh
set -e

# Create required runtime directories
mkdir -p /run/php /var/run/php
chown www-data:www-data /run/php /var/run/php

# Run initial configuration only if WordPress not installed
if [ ! -f /var/www/html/wp-config.php ]; then
    /usr/local/bin/configure.sh
fi

# Start PHP-FPM
exec php-fpm7.4 -F
