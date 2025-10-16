FROM alpine:3.18

RUN apk update && \
    apk add --no-cache mariadb mariadb-client bash

RUN mkdir -p /var/run/mysqld /var/lib/mysql

# Debug: listar archivos en el contexto de build
COPY . /tmp/build-context/
RUN ls -la /tmp/build-context/

# Copiar archivos específicos
COPY conf/mariadb.conf /etc/my.cnf
COPY tools/configure.sh /usr/local/bin/configure.sh

RUN chmod +x /usr/local/bin/configure.sh && \
    echo "=== File check ===" && \
    ls -la /usr/local/bin/configure.sh && \
    file /usr/local/bin/configure.sh

VOLUME /var/lib/mysql
EXPOSE 3306

# Temporal: usar sleep para debugging
CMD ["sleep", "3600"]
