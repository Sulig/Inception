FROM php:8.0-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
      mariadb-client \
      curl \
      less \
    && curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiamos el script de configuración
COPY tools/configure.sh /usr/local/bin/configure.sh
RUN chmod +x /usr/local/bin/configure.sh

WORKDIR /var/www/html
VOLUME [ "/var/www/html" ]
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/configure.sh"]
CMD ["php-fpm"]
