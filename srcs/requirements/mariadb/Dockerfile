# Usamos la penúltima versión estable de Alpine
FROM alpine:3.18

# Instalamos MariaDB
RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    && rm -rf /var/cache/apk/*

# Crear directorios necesarios
RUN mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql
RUN chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql
RUN chmod 755 /var/lib/mysql

# Copiar configuración
COPY conf/mariadb.conf /etc/mariadb.conf
RUN chown mysql:mysql /etc/mariadb.conf

# Copiar script de configuración
COPY tools/configure.sh /tmp/configure.sh
RUN chmod +x /tmp/configure.sh

# Puerto de MariaDB
EXPOSE 3306

# Volumen para datos
VOLUME /var/lib/mysql

USER mysql
# Comando de inicio
CMD ["/tmp/configure.sh"]
