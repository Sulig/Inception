FROM alpine:3.21

RUN apk update && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-json \
    php83-curl \
    php83-dom \
    php83-exif \
    php83-fileinfo \
    php83-mbstring \
    php83-openssl \
    php83-xml \
    php83-zip \
    php83-phar \
    php83-ctype \
    php83-tokenizer \
    php83-simplexml \
    wget \
    mariadb-client \
    curl \
    su-exec \
    shadow \
    netcat-openbsd \
    iputils \
    bind-tools

# Install WP-CLI (most stable version)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Create a wrapper for WP-CLI that uses the correct user
RUN echo '#!/bin/sh' > /usr/local/bin/wp-cli && \
    echo 'su-exec nobody:nobody /usr/local/bin/wp "$@" --path=/var/www/html' >> /usr/local/bin/wp-cli && \
    chmod +x /usr/local/bin/wp-cli

# Create necessary directories
RUN mkdir -p /var/www/html && \
    mkdir -p /var/run/php

# Download WordPress
RUN wget https://wordpress.org/wordpress-6.5.2.tar.gz -O /tmp/wordpress.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /tmp && \
    cp -r /tmp/wordpress/* /var/www/html/ && \
    rm -rf /tmp/wordpress* && \
    chown -R nobody:nobody /var/www/html

# Configure PHP-FPM to listen on all interfaces
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /etc/php83/php-fpm.d/www.conf && \
    sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php83/php-fpm.conf && \
    echo "clear_env = no" >> /etc/php83/php-fpm.d/www.conf

# Configuration script
COPY tools/configure.sh /configure.sh
RUN chmod +x /configure.sh

EXPOSE 9000

CMD ["/configure.sh"]
