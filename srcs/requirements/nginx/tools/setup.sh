#!/bin/sh
# srcs/requirements/nginx/tools/setup.sh
set -e

# Crear directorios necesarios
mkdir -p /etc/nginx/certs
mkdir -p /var/www/html
mkdir -p /run/nginx

# Generar certificado SSL
openssl req -x509 -nodes -days 365 \
    -subj "/C=FR/ST=42/L=Paris/O=42/OU=Student/CN=${DOMAIN_NAME}" \
    -newkey rsa:2048 \
    -keyout /etc/nginx/certs/localhost.key \
    -out /etc/nginx/certs/localhost.crt

# Aplicar variables de entorno al template
envsubst '${DOMAIN_NAME}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Verificar que la configuración es válida
nginx -t

# Iniciar Nginx en primer plano
exec nginx -g "daemon off;"
