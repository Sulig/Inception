# Dockerfile para MariaDB (Debian 12 / bookworm — penúltima estable)
FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# instalar mariadb (cliente + server)
RUN apt-get update && \
    apt-get install -y --no-install-recommends mariadb-server mariadb-client ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# crear directorio de datos y asignar permisos
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

# copiar entrypoint
COPY mariadb_conf.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb_conf.sh

EXPOSE 3306

USER root
# arrancar el entrypoint (sin background en el Dockerfile)
ENTRYPOINT ["mariadb_conf.sh"]
CMD ["mysqld"]
