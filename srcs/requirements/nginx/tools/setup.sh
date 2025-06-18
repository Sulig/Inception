#!/bin/bash
mkdir -p /etc/nginx/certs

openssl req -x509 -nodes -days 365 \
  -subj "/C=FR/ST=42/L=Paris/O=42/OU=Student/CN=login.42.fr" \
  -newkey rsa:2048 \
  -keyout /etc/nginx/certs/localhost.key \
  -out /etc/nginx/certs/localhost.crt

envsubst '$DOMAIN_NAME' \
  < /etc/nginx/sites-available/default.conf.template \
  > /etc/nginx/sites-enabled/default.conf

exec nginx -g 'daemon off;'
