# srcs/requirements/mariadb/Dockerfile
FROM alpine:3.18

RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client

# Crear directorio para la base de datos
RUN mkdir -p /var/lib/mysql
RUN chown -R mysql:mysql /var/lib/mysql

# Copiar script de configuración
COPY tools/configure.sh /tmp/configure.sh
RUN chmod +x /tmp/configure.sh

# Puerto de MariaDB
EXPOSE 3306

# Volumen para persistencia
VOLUME /var/lib/mysql

# Usar el script de configuración como entrypoint#
ENTRYPOINT ["/tmp/configure.sh"]
