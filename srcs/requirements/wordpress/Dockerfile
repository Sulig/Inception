FROM php:8.2-fpm-alpine

RUN apk update && apk add --no-cache \
    curl \
    mariadb-client \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    shadow

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo pdo_mysql zip

RUN curl -o wordpress.tar.gz -fSL "https://wordpress.org/latest.tar.gz" \
    && tar -xzf wordpress.tar.gz -C /usr/src/ \
    && rm wordpress.tar.gz

COPY tools/configure.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/configure.sh

# Configurar usuario y permisos
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
RUN chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

ENTRYPOINT ["configure.sh"]
CMD ["php-fpm", "-F"]
