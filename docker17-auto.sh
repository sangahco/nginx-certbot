#!/usr/bin/env bash

set -e

SCRIPT_BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "$SCRIPT_BASE_PATH"

###############################################
# Extract Environment Variables from .env file
# Ex. REGISTRY_URL="$(getenv REGISTRY_URL)"
###############################################
getenv(){
    local _env="$(printenv $1)"
    echo "${_env:-$(cat .env | awk 'BEGIN { FS="="; } /^'$1'/ {sub(/\r/,"",$2); print $2;}')}"
}

REGISTRY_URL="$(getenv REGISTRY_URL)"
CERTBOT_CERTS_PATH="$(getenv CERTBOT_CERTS_PATH)"
CERTBOT_WEBROOT="$(getenv CERTBOT_WEBROOT)"
CERTBOT_HOST="$(getenv CERTBOT_HOST)"
CERTBOT_EMAIL="$(getenv CERTBOT_EMAIL)"

FB_CONTAINER_ID_FILE=$PWD/fb.did

if [ -f "$FB_CONTAINER_ID_FILE" ]; then
    FB_DID=`cat "$FB_CONTAINER_ID_FILE"`
fi

usage() {
echo "Usage:  $(basename "$0") [MODE] [OPTIONS] [COMMAND]"
echo
echo "This script is for docker 1.7 to use with Centos/RedHat 6 only!"
echo "Download and install docker 1.7.1:"
echo "$ sudo -i"
echo "# wget https://s3.ap-northeast-2.amazonaws.com/sangah-b1/docker-engine-1.7.1-1.el6.x86_64.rpm"
echo "# yum localinstall --nogpgcheck docker-engine-1.7.1-1.el6.x86_64.rpm"
echo "# service docker start"
echo "# exit"
echo
echo "Options:"
echo
echo "Commands:"
echo "  up              Start the services"
echo "  down            Stop the services"
echo "  restart         Restart the services"
echo "  logs            Follow the logs on console"
echo "  login           Log in to a Docker registry"
echo
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    usage
    exit 1
fi

for i in "$@"
do
case $i in
    --help|-h)
        usage
        exit 1
        ;;
    *)
        break
        ;;
esac
done

echo "Arguments: $CONF_ARG"
echo "Command: $@"

if [ "$1" == "login" ]; then
    docker login $REGISTRY_URL
    exit 0

elif [ "$1" == "up" ]; then
    docker pull $REGISTRY_URL/nginx-certbot
    docker run \
    --volume "${CERTBOT_CERTS_PATH}:/etc/letsencrypt" \
    --volume "${CERTBOT_WEBROOT}:/usr/share/nginx/html" \
    --env "CERTBOT_WEBROOT=${CERTBOT_WEBROOT}" \
    --env "CERTBOT_HOST=${CERTBOT_HOST}" \
    --env "CERTBOT_EMAIL=${CERTBOT_EMAIL}" \
    ${CONF_ARG} \
    $REGISTRY_URL/nginx-certbot > $FB_CONTAINER_ID_FILE
    exit 0

fi