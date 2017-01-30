#!/bin/bash
set -e

nginx

echo "Generating certificate for ${LETSENCRYPT_HOST} - with email: ${LETSENCRYPT_EMAIL}"

exec /bin/sh /certbot-auto certonly \
    -n --agree-tos --email ${LETSENCRYPT_EMAIL} --webroot \
    -w /usr/share/nginx/html -d ${LETSENCRYPT_HOST}

exec "$@"