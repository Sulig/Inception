FROM alpine:3.18

RUN apk update && apk add --no-cache mariadb mariadb-client

RUN mkdir -p /run/mysqld
RUN chown mysql:mysql /run/mysqld

COPY tools/configure.sh /tmp/configure.sh
RUN chmod +x /tmp/configure.sh

EXPOSE 3306
VOLUME /var/lib/mysql

CMD ["/tmp/configure.sh"]
