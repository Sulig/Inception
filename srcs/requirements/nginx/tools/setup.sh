#!/bin/bash
set -e

mkdir -p /etc/nginx/certs

# Generate Certificate
openssl req -x509 -nodes -days 365 \
  -subj "/C=FR/ST=42/L=Paris/O=42/OU=Student/CN=${DOMAIN_NAME}" \
  -newkey rsa:2048 \
  -keyout /etc/nginx/certs/localhost.key \
  -out /etc/nginx/certs/localhost.crt

envsubst '${DOMAIN_NAME}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"
