#Last Debian Stable
FROM debian:bullseye

#Dowload MariaDB and update it to the last version
RUN apt update \
	&& apt install -y mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

#Copy configuration
COPY conf/mariadb.conf /etc/mysql/my.cnf
COPY tools/configure.sh   /usr/local/bin/configure.sh
RUN chmod +x /usr/local/bin/configure.sh

RUN mkdir -p /var/run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

VOLUME /var/lib/mysql

#MariaDB Port
EXPOSE 3306

#Execute
ENTRYPOINT ["/usr/local/bin/configure.sh"]
CMD ["mysqld"]
