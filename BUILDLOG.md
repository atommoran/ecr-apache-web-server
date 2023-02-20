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

Pushing this commit now to save the configuration file as is, next commit will:
* Implement deployment commands in cfn-deploy.sh
* Configure personal configuration, and add .gitignore to hide changes
* Make script to update image: build, push and then update the ECS service