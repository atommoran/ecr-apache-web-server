#!/bin/bash

BOOTSTRAP_STACK_NAME="ecs-apache-bootstrap"
ECR_NAME="apache-web-server"

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


showUsage () {
    echo "Description:"
    echo "    Bootstraps, creates and updates the cloudformation infrastructure for the ECS apache web server build."
    echo ""
    echo "Options:"
    echo "    bootstrap: Creates bootstrapping infrastructure and stores output."
}

if [ $# -eq 0 ]; then
  showUsage
else
    case "$1" in
        "bootstrap")
            bootstrapInfra
            ;;
        *)
            showUsage
            ;;
    esac
fi