#!/bin/sh

set -e

echo "Configuring NGINX..."

# Reemplazar el dominio en la configuración
sed -i "s/\${DOMAIN_NAME}/${DOMAIN_NAME}/g" /etc/nginx/conf.d/default.conf

# Generar certificados SSL autofirmados si no existen
if [ ! -f /etc/nginx/ssl/cert.pem ] || [ ! -f /etc/nginx/ssl/key.pem ]; then
    echo "Generating self-signed SSL certificate for ${DOMAIN_NAME}..."
    mkdir -p /etc/nginx/ssl

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/key.pem \
        -out /etc/nginx/ssl/cert.pem \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Inception/CN=${DOMAIN_NAME}"

    echo "SSL certificate generated successfully!"
fi

# Verificar que la configuración de NGINX es válida
echo "Testing NGINX configuration..."
nginx -t

echo "Starting NGINX..."
exec nginx -g 'daemon off;'
