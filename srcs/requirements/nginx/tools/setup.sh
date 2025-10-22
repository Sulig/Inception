#!/bin/sh
set -e

# Create necessary directories
mkdir -p /etc/nginx/certs
mkdir -p /var/www/html
mkdir -p /run/nginx

# Generate SSL certificate
openssl req -x509 -nodes -days 365 \
    -subj "/C=FR/ST=42/L=Paris/O=42/OU=Student/CN=${DOMAIN_NAME}" \
    -newkey rsa:2048 \
    -keyout /etc/nginx/certs/localhost.key \
    -out /etc/nginx/certs/localhost.crt

# Apply environment variables to the template
envsubst '${DOMAIN_NAME}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Verify that the configuration is valid
nginx -t

# Start Nginx in the foreground
exec nginx -g "daemon off;"
