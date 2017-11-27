#!/bin/bash
set -e

if [ "$CERTBOT_STANDALONE" == "true" ]; then
  nginx
fi

echo "Generating certificate with the following settings:"
echo "- host:                 ${CERTBOT_HOST}"
echo "- email:                ${CERTBOT_EMAIL}"
echo "- standalone mode:      ${CERTBOT_STANDALONE}"

if [ $# -eq 0 ]; then
    exec /bin/sh /certbot-auto certonly \
        --expand \
        --non-interactive \
        --agree-tos \
        --no-self-upgrade \
        --email ${CERTBOT_EMAIL} \
        --webroot \
        --webroot-path /usr/share/nginx/html \
        --domains ${CERTBOT_HOST}
        #--force-renewal
fi

exec "$@"