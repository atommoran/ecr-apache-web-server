#!/bin/bash

BOOTSTRAP_STACK_NAME="ecs-apache-bootstrap"
ECR_NAME="apache-web-server"

ECS_INFRA_STACK_NAME="ecs-apache-infra"

ECR_REPOSITORY_URI=$(jq -r '.Outputs[] | select(.OutputKey=="RepositoryUri") | .OutputValue' stack_descriptions/bootstrap_stack_description.json)


bootstrapInfra () {
    if describe_output=$(aws cloudformation describe-stacks --stack-name $BOOTSTRAP_STACK_NAME 2>/dev/null)
    then
        echo "Bootstrap stack already created."
    else
        echo "Creating bootstrap stack..."
        aws cloudformation create-stack \
            --stack-name $BOOTSTRAP_STACK_NAME \
            --template-body file://cloudformation/bootstrap_stack.yaml \
            --parameters ParameterKey=EcrName,ParameterValue=$ECR_NAME
        echo "Bootstrap stack created."
        describe_output=$(aws cloudformation describe-stacks --stack-name $BOOTSTRAP_STACK_NAME 2>/dev/null)
    fi

    echo "Writing describe-stack json output to stack_descriptions/bootstrap_stack_description.json"
    echo $describe_output | jq '.Stacks[0]' > stack_descriptions/bootstrap_stack_description.json
}

deleteBootstrap () {
    echo "Deleting bootstrap stack..."
    aws cloudformation delete-stack \
        --stack-name $BOOTSTRAP_STACK_NAME
}

describeInfra () {
    describe_output=$(aws cloudformation describe-stacks --stack-name $ECS_INFRA_STACK_NAME)
    echo "Writing describe-stack json output to stack_descriptions/ecs_infra_stack_description.json"
    echo $describe_output | jq '.Stacks[0]' > stack_descriptions/ecs_infra_stack_description.json
}

createInfra () {
    gsed -i "s|--- EcsImageUri IS DYNAMICALLY REPLACED ---|$ECR_REPOSITORY_URI|" ecr-infra-configuration.json

    echo "Creating ECS infra stack..."
    aws cloudformation create-stack \
        --stack-name $ECS_INFRA_STACK_NAME \
        --template-body file://cloudformation/ecs_infra.yaml \
        --parameters file://ecr-infra-configuration.json \
        --capabilities CAPABILITY_IAM
    echo "ECS infra stack created."

    describeInfra
}

updateInfra () {
    echo "Updating ECS infra stack..."
    aws cloudformation update-stack \
        --stack-name $ECS_INFRA_STACK_NAME \
        --template-body file://cloudformation/ecs_infra.yaml \
        --parameters file://ecr-infra-configuration.json \
        --capabilities CAPABILITY_IAM
    echo "ECS infra stack updated."

    describeInfra
}

deleteInfra () {
    echo "Deleting ECS infra stack..."
    aws cloudformation delete-stack \
        --stack-name $ECS_INFRA_STACK_NAME
}

showUsage () {
    echo "Description:"
    echo "    Bootstraps, creates and updates the cloudformation infrastructure for the ECS apache web server build."
    echo ""
    echo "Options:"
    echo "    bootstrap: Creates bootstrapping infrastructure and stores output."
    echo "    delete-bootstrap: Deletes bootstrapping infrastructure and removes output."
    echo "    create: Create cloudformation stack for ECS web server infrastructure."
    echo "    describe: Describe current state of cloudformation ECS stack and prints to description file."
    echo "    update: Update cloudformation stack for ECS web server infrastructure."
    echo "    delete: Deletes ECS cloudformation stack."
}

if [ $# -eq 0 ]; then
  showUsage
else
    case "$1" in
        "bootstrap")
            bootstrapInfra
            ;;
        "delete-bootstrap")
            deleteBootstrap
            ;;
        "create")
            createInfra
            ;;
        "describe")
            describeInfra
            ;;
        "update")
            updateInfra
            ;;
        "delete")
            deleteInfra
            ;;
        *)
            showUsage
            ;;
    esac
fi