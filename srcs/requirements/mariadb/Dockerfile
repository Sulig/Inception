FROM alpine:3.18

# Install MariaDB and bash (importante: Alpine no tiene bash por defecto)
RUN apk update && \
    apk add --no-cache mariadb mariadb-client bash && \
    rm -rf /var/cache/apk/*

# Create directories first
RUN mkdir -p /var/run/mysqld /var/lib/mysql /var/log/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql /var/log/mysql

# Copy configuration
COPY conf/mariadb.conf /etc/my.cnf
COPY tools/configure.sh /usr/local/bin/configure.sh

# Verify the file was copied and set permissions
RUN ls -la /usr/local/bin/configure.sh && \
    chmod +x /usr/local/bin/configure.sh && \
    ls -la /usr/local/bin/configure.sh

VOLUME /var/lib/mysql
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/configure.sh"]
CMD ["mysqld", "--user=mysql"]
