FROM alpine:3.18

# Instalar PHP, FPM y extensiones necesarias para WordPress
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
    php81-gd \
    php81-intl \
    php81-phar \
    php81-tokenizer \
    php81-simplexml \
    php81-xmlreader \
    php81-xmlwriter \
    php81-ctype \
    php81-session \
    php81-iconv \
    wget \
    curl \
    mariadb-client \
    && rm -rf /var/cache/apk/*

# Crear directorios necesarios
RUN mkdir -p /var/www/html /run/php

# Descargar y instalar WordPress CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copiar configuración de PHP-FPM
COPY conf/www.conf /etc/php81/php-fpm.d/www.conf

# Copiar script de configuración
COPY tools/configure.sh /tmp/configure.sh
RUN chmod +x /tmp/configure.sh

# Puerto de PHP-FPM
EXPOSE 9000

# Volumen para los archivos de WordPress
VOLUME /var/www/html

# Comando de inicio
CMD ["/tmp/configure.sh"]
