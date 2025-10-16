# Usamos la penúltima versión estable de Alpine
FROM alpine:3.18

# Instalar NGINX y OpenSSL para generar certificados
RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    && rm -rf /var/cache/apk/*

# Crear directorios necesarios
RUN mkdir -p /var/www/html /etc/nginx/ssl /etc/nginx/conf.d /run/nginx

# Copiar configuración de NGINX
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Copiar script de configuración
COPY tools/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

# Exponer el puerto 443 (HTTPS)
EXPOSE 443

# Comando de inicio
CMD ["/tmp/setup.sh"]
