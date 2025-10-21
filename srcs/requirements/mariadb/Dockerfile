# srcs/requirements/mariadb/Dockerfile
FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# Instalar mariadb (cliente + server)
RUN apt-get update && \
    apt-get install -y --no-install-recommends mariadb-server mariadb-client ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Crear directorio de datos y asignar permisos
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

# Copiar entrypoint desde el subdirectorio tools
COPY tools/mariadb_conf.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb_conf.sh

EXPOSE 3306
VOLUME /var/lib/mysql

ENTRYPOINT ["/usr/local/bin/mariadb_conf.sh"]
CMD ["mysqld"]
