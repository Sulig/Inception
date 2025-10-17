FROM alpine:3.18

RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    gettext

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 443
ENTRYPOINT ["/setup.sh"]
