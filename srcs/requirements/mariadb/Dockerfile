FROM alpine:3.18

RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    && rm -rf /var/cache/apk/*

# Crear directorios como root primero
RUN mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql

# Cambiar propietario de los directorios ANTES de copiar cualquier cosa
RUN chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql

# Copiar configuración
COPY conf/mariadb.cnf /etc/my.cnf
RUN chown mysql:mysql /etc/my.cnf

# Script simplificado - sin operaciones de chown
COPY tools/configure.sh /tmp/configure.sh
RUN chmod +x /tmp/configure.sh

EXPOSE 3306

USER mysql
CMD ["/tmp/configure.sh"]
