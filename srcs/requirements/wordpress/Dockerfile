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
    php81-simplexml \
    php81-ctype \
    php81-iconv \
    wget \
    mariadb-client \
    curl

# Instalar WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Crear directorios necesarios
RUN mkdir -p /var/www/html && \
    mkdir -p /var/run/php

# Descargar WordPress
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /tmp && \
    cp -r /tmp/wordpress/* /var/www/html/ && \
    rm -rf /tmp/wordpress* && \
    chown -R nobody:nobody /var/www/html

# Configurar PHP-FPM
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /etc/php81/php-fpm.d/www.conf && \
    sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php81/php-fpm.conf

# Script de configuración
COPY tools/configure.sh /configure.sh
RUN chmod +x /configure.sh

EXPOSE 9000

CMD ["/configure.sh"]
