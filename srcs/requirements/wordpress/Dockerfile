FROM alpine:3.18

RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-json \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-mbstring \
    php81-openssl \
    php81-xml \
    php81-zip \
    php81-phar \
    php81-ctype \
    php81-tokenizer \
    php81-simplexml \
    wget \
    mariadb-client \
    curl \
	su-exec \
    shadow

# Instalar WP-CLI (versión más estable)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Crear un wrapper para WP-CLI que use el usuario correcto
RUN echo '#!/bin/sh' > /usr/local/bin/wp-cli && \
    echo 'su-exec nobody:nobody /usr/local/bin/wp "$@" --path=/var/www/html' >> /usr/local/bin/wp-cli && \
    chmod +x /usr/local/bin/wp-cli

# Crear directorios necesarios
RUN mkdir -p /var/www/html && \
    mkdir -p /var/run/php

# Descargar WordPress
RUN wget https://wordpress.org/wordpress-6.5.2.tar.gz -O /tmp/wordpress.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /tmp && \
    cp -r /tmp/wordpress/* /var/www/html/ && \
    rm -rf /tmp/wordpress* && \
    chown -R nobody:nobody /var/www/html

# Configurar PHP-FPM para escuchar en todas las interfaces
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /etc/php81/php-fpm.d/www.conf && \
    sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php81/php-fpm.conf && \
    echo "clear_env = no" >> /etc/php81/php-fpm.d/www.conf

# Script de configuración
COPY tools/configure.sh /configure.sh
RUN chmod +x /configure.sh

EXPOSE 9000

CMD ["/configure.sh"]
