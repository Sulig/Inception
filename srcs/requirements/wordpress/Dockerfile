FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      php-fpm php-mysql php-curl php-dom \
      php-mbstring php-gd php-xml curl && \
    curl -sS https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
      -o /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Crea el symlink para php-fpm
RUN ln -s /usr/sbin/php-fpm7.4 /usr/local/bin/php-fpm

# Copy configuration tools
COPY tools/ /usr/local/bin/
RUN chmod +x /usr/local/bin/configure.sh /usr/local/bin/entrypoint.sh

# Setup volumes and ports
WORKDIR /var/www/html
VOLUME [ "/var/www/html" ]
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
