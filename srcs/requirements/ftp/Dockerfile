FROM stilliard/pure-ftpd:hardened

RUN -itd --name ftpd_server -p 21:21 -p 30000-30009:30000-30009 \
	-v ftp:/var/www/html -e "PUBLICHOST=localhost" \
	stilliard/pure-ftpd:hardened

RUN pure-pw useradd admin -f /etc/pure-ftpd/passwd/pureftpd.passwd \
	-m -u ftpuser -d /var/www/html

EXPOSE 21
EXPOSE 30000-30009

CMD ["-it ftpd_server /bin/bash"]
