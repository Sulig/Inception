#Last Debian Stable
FROM debian:bullseye-slim

#Dowload MariaDB and update it to the last version
RUN apt update && apt upgrade -y \
	&& apt install -y mariadb-server

#Copy configuration
COPY conf/mariadb.conf /etc/mysql/my.cnf

#Copy start scripts
#COPY tools/configure.sh /tmp/configure.sh
#RUN chmod +x /tmp/configure.sh

#MariaDB Port
EXPOSE 3306

#Execute
ENTRYPOINT ["/tmp/configure.sh"]
