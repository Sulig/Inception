FROM alpine:3.18

# Instalar lo mínimo indispensable
RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-curl \
    php81-dom \
    php81-mbstring \
    php81-openssl \
    php81-xml \
    php81-zip \
    php81-gd \
    php81-json \
    wget \
    mariadb-client

# Crear directorios
RUN mkdir -p /var/www/html /run/php

# Instalar WP-CLI
RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /usr/local/bin/wp

# Copiar configuración
COPY conf/www.conf /etc/php81/php-fpm.d/www.conf
COPY tools/configure.sh /tmp/configure.sh
RUN chmod +x /tmp/configure.sh

EXPOSE 9000
VOLUME /var/www/html

CMD ["/tmp/configure.sh"]
