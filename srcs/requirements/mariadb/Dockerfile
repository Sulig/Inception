# srcs/requirements/mariadb/Dockerfile
FROM alpine:3.18

RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    su-exec

# Crear directorio para la base de datos
RUN mkdir -p /var/lib/mysql
RUN chown -R mysql:mysql /var/lib/mysql
RUN chmod 755 /var/lib/mysql

# Copiar script de configuración
COPY tools/mariadb_conf.sh /usr/local/bin/mariadb_conf.sh
RUN chmod +x /usr/local/bin/mariadb_conf.sh

# Puerto de MariaDB
EXPOSE 3306

# Volumen para persistencia
VOLUME /var/lib/mysql

# Usar el script de configuración como entrypoint
ENTRYPOINT ["/usr/local/bin/mariadb_conf.sh"]
