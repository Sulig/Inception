FROM alpine:3.18

RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client

RUN mkdir -p /var/lib/mysql /run/mysqld /etc/mysql
COPY conf/my.cnf /etc/mysql/my.cnf
COPY tools/mariadb_conf.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb_conf.sh

# Puerto de MariaDB
EXPOSE 3306

# Volumen para persistencia
VOLUME /var/lib/mysql

# Usar el script de configuración como entrypoint
ENTRYPOINT ["/usr/local/bin/mariadb_conf.sh"]
