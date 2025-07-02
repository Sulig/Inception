FROM debian:bullseye

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	php php-fpm php-mysql php-curl php-dom php-mbstring php-gd php-xml \
	curl less unzip wget tar && \
	curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x /usr/local/bin/wp && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# Descargar WordPress
RUN curl -o wordpress.tar.gz -fSL "https://wordpress.org/latest.tar.gz" \
    && tar -xzf wordpress.tar.gz -C /usr/src/ \
    && rm wordpress.tar.gz

COPY tools/configure.sh /usr/local/bin/configure.sh
RUN chmod +x /usr/local/bin/configure.sh

WORKDIR /var/www/html
VOLUME [ "/var/www/html" ]

# port
EXPOSE 9000

#----
ENTRYPOINT ["/usr/local/bin/configure.sh"]
CMD ["php-fpm"]

