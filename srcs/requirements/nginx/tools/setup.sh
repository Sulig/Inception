#!/bin/sh
set -e

# Create necessary directories
mkdir -p /etc/nginx/certs
mkdir -p /var/www/html
mkdir -p /run/nginx
mkdir -p /var/log/nginx

# Generate proper SSL certificate for the domain
echo "📜 Generating SSL certificate for ${DOMAIN_NAME}..."
openssl req -x509 -nodes -days 365 \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Student/CN=${DOMAIN_NAME}" \
    -addext "subjectAltName=DNS:${DOMAIN_NAME},DNS:www.${DOMAIN_NAME}" \
    -newkey rsa:2048 \
    -keyout /etc/nginx/certs/nginx.key \
    -out /etc/nginx/certs/nginx.crt

# Set proper permissions
chmod 600 /etc/nginx/certs/nginx.key
chmod 644 /etc/nginx/certs/nginx.crt

# Apply environment variables to the template
echo "🌐 Configuring domain: ${DOMAIN_NAME}"
envsubst '${DOMAIN_NAME}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Verify that the configuration is valid
echo "✅ Testing Nginx configuration..."
nginx -t

echo "🚀 Starting Nginx..."
# Start Nginx in the foreground
exec nginx -g "daemon off;"s
