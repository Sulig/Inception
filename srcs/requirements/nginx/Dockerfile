FROM debian:bullseye

RUN apt update && \
	apt install -y \
	nginx \
	openssl \
	gettext-base \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/default.conf.template /etc/nginx/sites-available/default.conf.template
COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 443
ENTRYPOINT ["/setup.sh"]
