#!/bin/sh
set -e

# Run initial configuration only if WordPress not installed
if [ ! -f wp-config.php ]; then
    /usr/local/bin/configure.sh
fi

# Start PHP-FPM
exec php-fpm7.4 -F
