FROM alpine:3.18

# Install MariaDB
RUN apk update && \
    apk add --no-cache mariadb mariadb-client && \
    rm -rf /var/cache/apk/*

# Copy configuration
COPY conf/mariadb.conf /etc/my.cnf
COPY tools/configure.sh /usr/local/bin/configure.sh
RUN chmod +x /usr/local/bin/configure.sh

# Create directories and set permissions
RUN mkdir -p /var/run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

VOLUME /var/lib/mysql
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/configure.sh"]
CMD ["mysqld", "--user=mysql"]
