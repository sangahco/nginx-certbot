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

DOCKER_COMPOSE_VERSION="1.29.2"
CONF_ARG="-f docker-compose-prod.yml"
PATH=$PATH:/usr/local/bin/
IMAGE_NAME="$(getenv IMAGE_NAME)"
REGISTRY_URL="$(getenv REGISTRY_URL)"

########################################
# Install docker-compose
# DOCKER_COMPOSE_VERSION need to be set
########################################
install_docker_compose() {
    sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    return 0
}

if ! command -v docker-compose >/dev/null 2>&1; then
    install_docker_compose || true
elif [[ "$(docker-compose version --short)" != "$DOCKER_COMPOSE_VERSION" ]]; then
    install_docker_compose || true
fi

usage() {
echo "Usage:  $(basename "$0") [MODE] [OPTIONS] [COMMAND]"
echo 
echo "Mode:"
echo "  --prod             Production mode with no web server"
echo "  --dev              Development mode with no web server"
echo "  --dev-standalone   Development mode with web server included"
echo "  --prod-standalone  Production mode with web server included"
echo
echo "Options:"
echo "  --help          Show this help message"
echo
echo "Commands:"
echo "  up              Start the services"
echo "  down            Stop the services"
echo "  ps              Show the status of the services"
echo "  logs            Follow the logs on console"
echo "  remove-all      Remove all containers"
echo "  stop-all        Stop all containers running"
echo "  build           Build the image"
echo "  publish         Publish the image to the registry"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

for i in "$@"; do
    case $i in
        --prod)
            CONF_ARG="-f docker-compose-prod.yml"
            shift
            ;;
        --dev)
            CONF_ARG="-f docker-compose.yml"
            shift
            ;;
        --prod-standalone)
            CONF_ARG="-f docker-compose-prod-standalone.yml"
            shift
            ;;
        --dev-standalone)
            CONF_ARG="-f docker-compose-standalone.yml"
            shift
            ;;
        --help|-h)
            usage
            exit 1
            ;;
        *)
            ;;
    esac
done

echo "Arguments: $CONF_ARG"
echo "Command: $@"

if [ "$1" == "login" ]; then
    docker login $REGISTRY_URL
    exit 0

elif [ "$1" == "up" ]; then
    docker-compose $CONF_ARG pull
    docker-compose $CONF_ARG build --pull
    docker-compose $CONF_ARG up -d --remove-orphans
    exit 0

elif [ "$1" == "stop-all" ]; then
    if [ -n "$(docker ps --format {{.ID}})" ]
    then docker stop $(docker ps --format {{.ID}}); fi
    exit 0

elif [ "$1" == "remove-all" ]; then
    if [ -n "$(docker ps -a --format {{.ID}})" ]
    then docker rm $(docker ps -a --format {{.ID}}); fi
    exit 0

elif [ "$1" == "logs" ]; then
    shift
    docker-compose $CONF_ARG logs -f --tail 200 "$@"
    exit 0

elif [ "$1" == "build" ]; then
    if [ -z "$REGISTRY_URL" ]; then echo "REGISTRY_URL not defined."; exit 1; fi
    if [ -z "$IMAGE_NAME" ]; then echo "IMAGE_NAME not defined."; exit 1; fi
    
    docker build -t $REGISTRY_URL/$IMAGE_NAME was
    exit 0

elif [ "$1" == "publish" ]; then
    if [ -z "$REGISTRY_URL" ]; then echo "REGISTRY_URL not defined."; exit 1; fi
    if [ -z "$IMAGE_NAME" ]; then echo "IMAGE_NAME not defined."; exit 1; fi
    
    docker login $REGISTRY_URL
    docker push $REGISTRY_URL/$IMAGE_NAME
    exit 0
fi

docker-compose $CONF_ARG "$@"
