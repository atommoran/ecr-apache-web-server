#!/bin/bash

# Built off of: https://github.com/WinterWindSoftware/simple-express-app/blob/master/docker-task.sh

IMAGE_NAME="apache-web-server"
CONTAINER_NAME="apache-web-server_local"
HOST_PORT=8080
CONTAINER_PORT=80

IMAGE_VERSION="0.2"

REPOSITORY_URI=$(jq -r '.Outputs[] | select(.OutputKey=="RepositoryUri") | .OutputValue' stack_descriptions/bootstrap_stack_description.json)

# Builds the Docker image and tags it with latest version number.
buildImage () {
    echo Building Image Version: $IMAGE_VERSION ...
    docker buildx build --platform=linux/amd64 -t $IMAGE_NAME:latest -t $IMAGE_NAME:$IMAGE_VERSION .
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

pushImage () {
    docker tag $IMAGE_NAME:latest $REPOSITORY_URI:latest
    docker tag $IMAGE_NAME:$IMAGE_VERSION $REPOSITORY_URI:$IMAGE_VERSION
    aws ecr get-login-password | docker login --username AWS --password-stdin $REPOSITORY_URI
    docker push $REPOSITORY_URI:latest
    docker push $REPOSITORY_URI:$IMAGE_VERSION
}

updateEcs () {
    cluster_name=$(jq -r '.Outputs[] | select(.OutputKey=="ecscluster") | .OutputValue' stack_descriptions/ecs_infra_stack_description.json)
    service_name=$(jq -r '.Outputs[] | select(.OutputKey=="ecsservice") | .OutputValue' stack_descriptions/ecs_infra_stack_description.json)

    aws ecs update-service \
        --cluster $cluster_name \
        --service $service_name \
        --force-new-deployment
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
    echo "    push: Pushes image to ECR repository (must run './ecr-deploy.sh bootstrap' first)."
    echo "    update-ecs: Forces new deployment for the ECS service to use new image."
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
        "push")
            pushImage
            ;;
        "update-ecs")
            updateEcs
            ;;
        *)
            showUsage
            ;;
    esac
fi