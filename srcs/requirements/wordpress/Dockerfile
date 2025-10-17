# srcs/requirements/wordpress/Dockerfile
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
    wget \
    mariadb-client \
    openssl

# Crear directorios necesarios
RUN mkdir -p /var/www/html && \
    mkdir -p /var/run/php && \
    chown -R nobody:nobody /var/www/html && \
    chown nobody:nobody /var/run/php

# Descargar WordPress
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /tmp && \
    cp -r /tmp/wordpress/* /var/www/html/ && \
    rm -rf /tmp/wordpress* && \
    chown -R nobody:nobody /var/www/html

# Configurar PHP-FPM para escuchar en todas las interfaces
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /etc/php81/php-fpm.d/www.conf && \
    sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php81/php-fpm.conf && \
    sed -i 's/user = nobody/user = nobody/g' /etc/php81/php-fpm.d/www.conf && \
    sed -i 's/group = nobody/group = nobody/g' /etc/php81/php-fpm.d/www.conf

# Copiar script de configuración
COPY tools/configure.sh /usr/local/bin/configure.sh
RUN chmod +x /usr/local/bin/configure.sh

EXPOSE 9000

CMD ["/usr/local/bin/configure.sh"]
