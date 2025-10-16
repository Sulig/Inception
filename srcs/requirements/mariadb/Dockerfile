FROM alpine:3.18

# Install MariaDB with client and dependencies
RUN apk update && \
    apk add --no-cache \
        mariadb \
        mariadb-client \
        mariadb-server-utils \
        bash \
        tzdata \
        && rm -rf /var/cache/apk/*

# Create all necessary directories with proper permissions
RUN mkdir -p /var/run/mysqld /var/lib/mysql /var/log/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql /var/log/mysql

# Copy configuration files
COPY conf/mariadb.conf /etc/my.cnf
COPY tools/configure.sh /usr/local/bin/configure.sh

# Set permissions and verify
RUN chmod +x /usr/local/bin/configure.sh && \
    chown mysql:mysql /usr/local/bin/configure.sh

VOLUME /var/lib/mysql
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/configure.sh"]
CMD ["mysqld", "--user=mysql"]
