FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Instal necessary utilies && add sury repo sury for PHP 8.3
RUN apt-get update && apt-get install -y \
    ca-certificates apt-transport-https lsb-release gnupg curl wget unzip \
    gnupg2 gosu mariadb-client netcat-openbsd procps \
  && curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php-sury.gpg \
  && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
  && apt-get update

# Instal PHP 8.3 and util extensions
RUN apt-get install -y \
    php8.3-fpm php8.3-mysql php8.3-curl php8.3-xml php8.3-mbstring php8.3-zip php8.3-cli \
    php8.3-gd php8.3-intl \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instal WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Create WP-CLI wrapper to ejecute as www-data (with gosu)
RUN printf '#!/bin/sh\nexec gosu www-data:www-data /usr/local/bin/wp "$@" --path=/var/www/html\n' > /usr/local/bin/wp-cli \
    && chmod +x /usr/local/bin/wp-cli

# Create dirs & own it
RUN mkdir -p /var/www/html /var/run/php && chown -R www-data:www-data /var/www/html

# Download WordPress
RUN wget https://wordpress.org/wordpress-6.5.2.tar.gz -O /tmp/wordpress.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /tmp \
    && cp -r /tmp/wordpress/* /var/www/html/ \
    && rm -rf /tmp/wordpress* \
    && chown -R www-data:www-data /var/www/html

# Configuration script
COPY tools/configure.sh /configure.sh
RUN chmod +x /configure.sh

EXPOSE 9000

CMD ["/configure.sh"]
