# Build Log

## 0.1 - Local Docker Build

* Wrote a simple index.html under server-files/
* Created Dockerfile for httpd image with the index.html
* Wrote docker-run.sh to run the docker commands

## 0.2 - Bootstrapping ECR

* Created bootstrapp CFN stack, which currently only includes an ECR repository
* Added cfn-deploy to run cloudformation aws-cli commands in controlled manner
* Adding stack descriptions and reading RepositoryUri to push image
