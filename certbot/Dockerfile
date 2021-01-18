FROM certbot/certbot:v1.11.0
LABEL maintainer="Emanuele Disco <emanuele.disco@sangah.com>"

RUN mkdir -p /usr/share/nginx/html
RUN mkdir -p /run/nginx

RUN apk update
RUN apk add nginx
COPY ./nginx/default.conf /etc/nginx/conf.d

COPY ./docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]