#!/bin/bash

# Built off of: https://github.com/WinterWindSoftware/simple-express-app/blob/master/docker-task.sh

IMAGE_NAME="apache-web-server"
CONTAINER_NAME="apache-web-server_local"
HOST_PORT=8080
CONTAINER_PORT=80

IMAGE_VERSION="0.1"

# Builds the Docker image and tags it with latest version number.
buildImage () {
    echo Building Image Version: $IMAGE_VERSION ...
    docker build -t $IMAGE_NAME:latest -t $IMAGE_NAME:$IMAGE_VERSION ./
    echo Build complete.
}

# Runs the container locally.
runContainer () {
    docker run --rm \
        --name $CONTAINER_NAME \
        -p $HOST_PORT:$CONTAINER_PORT \
        -d $IMAGE_NAME
    echo Container started. Open browser at http://localhost:$HOST_PORT .
}

# Shows the usage for the script.
showUsage () {
    echo "Description:"
    echo "    Builds, runs and pushes Docker image '$IMAGE_NAME'."
    echo ""
    echo "Options:"
    echo "    build: Builds a Docker image ('$IMAGE_NAME')."
    echo "    run-local: Runs a container based on an existing Docker image ('$IMAGE_NAME')."
    echo "    build-run: Builds a Docker image and runs the container."
}

if [ $# -eq 0 ]; then
  showUsage
else
    case "$1" in
        "build")
            buildImage
            ;;
        "run-local")
            runContainer
            ;;
        "build-run")
            buildImage
            runContainer
            ;;
        *)
            showUsage
            ;;
    esac
fi