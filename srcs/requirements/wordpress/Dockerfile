FROM debian:bullseye

# Install tini for proper signal handling
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    php php-fpm php-mysql php-curl php-dom \
    php-mbstring php-gd php-xml curl && \
    curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download WordPress
RUN curl -o wordpress.tar.gz -fSL "https://wordpress.org/latest.tar.gz" \
    && tar -xzf wordpress.tar.gz -C /usr/src/ \
    && rm wordpress.tar.gz

# Copy configuration tools
COPY tools/ /usr/local/bin/
RUN chmod +x /usr/local/bin/configure.sh /usr/local/bin/entrypoint.sh

# Setup volumes and ports
WORKDIR /var/www/html
VOLUME [ "/var/www/html" ]
EXPOSE 9000

# Use tini as init
ENTRYPOINT ["/tini", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]
