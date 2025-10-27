FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-json \
    php-curl \
    php-dom \
    php-exif \
    php-fileinfo \
    php-mbstring \
    php-xml \
    php-zip \
    php-phar \
    php-ctype \
    php-tokenizer \
    wget \
    mariadb-client \
    curl \
    iputils-ping \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI (most stable version)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Create a wrapper for WP-CLI that uses the correct user
RUN echo '#!/bin/sh' > /usr/local/bin/wp-cli && \
    echo 'sudo -u www-data /usr/local/bin/wp "$@" --path=/var/www/html' >> /usr/local/bin/wp-cli && \
    chmod +x /usr/local/bin/wp-cli

# Create necessary directories
RUN mkdir -p /var/www/html && \
    mkdir -p /var/run/php

# Download WordPress
RUN wget https://wordpress.org/wordpress-6.5.2.tar.gz -O /tmp/wordpress.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /tmp && \
    cp -r /tmp/wordpress/* /var/www/html/ && \
    rm -rf /tmp/wordpress* && \
    chown -R www-data:www-data /var/www/html

# Configure PHP-FPM to listen on all interfaces
RUN sed -i 's/^listen = \/run\/php\/php7.4-fpm.sock/listen = 0.0.0.0:9000/g' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/7.4/fpm/php-fpm.conf && \
    echo "clear_env = no" >> /etc/php/7.4/fpm/pool.d/www.conf

# Configuration script
COPY tools/configure.sh /configure.sh
RUN chmod +x /configure.sh

EXPOSE 9000

CMD ["/configure.sh"]
