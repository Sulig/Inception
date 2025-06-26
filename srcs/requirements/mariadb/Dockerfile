#Last Debian Stable
FROM debian:bullseye-slim

# Standart group mysql and user
RUN groupadd -r -g 999 mysql && \
    useradd -r -u 999 -g mysql mysql

#Dowload MariaDB and update it to the last version
RUN apt update && apt upgrade -y \
	&& apt install -y mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

#Copy configuration
#COPY conf/mariadb.conf /etc/mysql/my.cnf

# Give all permisions to continue
RUN mkdir -p /var/run/mysqld \
	&& chown -R mysql:mysql /var/run/mysqld \
	&& chmod 777 /var/run/mysqld

#Copy start scripts
#COPY tools/configure.sh /tmp/configure.sh
#RUN chmod +x /tmp/configure.sh

VOLUME /var/lib/mysql

#MariaDB Port
EXPOSE 3306

#Execute
#ENTRYPOINT ["/tmp/configure.sh"]
