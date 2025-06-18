#PHP version
FROM php:8.0-fpm

###
RUN apt-get update && apt-get install -y --no-install-recommends \
	mariadb-client unzip \
	&& docker-php-ext-install mysqli pdo pdo_mysql \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

##
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html

##
COPY tools/configure.sh /usr/local/bin/configure.sh
RUN chmod +x /usr/local/bin/configure.sh

# Data Base
VOLUME [ "/var/www/html" ]

# Port
EXPOSE 9000

#Ejecute script (configure wordpress) and start php
ENTRYPOINT ["configure.sh"]
CMD ["php-fpm"]
