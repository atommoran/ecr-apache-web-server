# Build Log

## 0.1 - Local Docker Build

* Wrote a simple index.html under server-files/
* Created Dockerfile for httpd image with the index.html
* Wrote docker-run.sh to run the docker commands

## 0.2 - Bootstrapping ECR

* Created bootstrapp CFN stack, which currently only includes an ECR repository
* Added cfn-deploy to run cloudformation aws-cli commands in controlled manner
* Adding stack descriptions and reading RepositoryUri to push image

## 0.3 - Cloudformation template and configuration file

* Created the ecs_infra.yaml CloudFormation template, modifying an AWS Documentation example
* Made configuration json file: ecr-infra-configuration.json

## 0.4 - Cloudformation deployment
* Implemented deployment commands in cfn-deploy.sh to create, update and delete ECS stack
* Granted ECR IAM permissions to EC2Role in EC2 infra stack, to pull image
* Fixed arm64 to x86 image issues by using docker buildx
* Added .gitingore to hide changes to ecr-infra-configuration.json

## 0.5 - Updating the ECS image
* Added update-ecs to docker-run.sh to force new deployment of ECS (and so take on a new image)
* Made a small chaneg to index.html and the version number to test the new deployment
