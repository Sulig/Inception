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
    wget

# Descargar WordPress
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
RUN tar -xzf /tmp/wordpress.tar.gz -C /tmp
RUN mv /tmp/wordpress/* /var/www/
RUN rm -rf /tmp/wordpress*

# Configurar PHP-FPM
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php81/php-fpm.d/www.conf
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php81/php-fpm.conf

# Crear directorio y configurar permisos
RUN mkdir -p /var/www
RUN chown -R nobody:nobody /var/www

# Puerto de PHP-FPM
EXPOSE 9000

# Iniciar PHP-FPM en primer plano
CMD ["php-fpm81", "-F"]
