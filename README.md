# ops-teraform
Terraform 

# provider
AWS

# Project Description
 We are using aws as a cloud provider in this project. We have setup below services 
 - ec2 for jenkins master
 - ec2 for jenkins slave
 - ec2 for app server (where node js app will be run)
 - ecr for pushing the image from the jenkins pipeline

 # Workflow
 - ## EC2 (Jenkins master)
   we have run the scripts while creating the ec2 server using the userdata (provided by aws) to setup the master node for our jenkins
   ### installed tools and utilities
   - java
   - jenkins

 - ## EC2 (Jenkins master)
   We have run the scripts for setup the ec2 server where we will setup the docker environment for our jenkins slave node 
   ### installed tools and utilities
   - Docker

 - ## EC2 (node app server)
   We have setup the node app server using provisioner where we will setup various services 
   ### setup tools ans utilities
   - copied blue-green-deploy.sh 
   - copied docker compose files for treafik and node service
   - copied treafik.yml file which is the configration file for treafik

   ### installed tools and utilities
   - installed aws cli
   - installed docker
   - installed docker-compose

 - ## ECR
   no external setup

# Setup
create the terraform.tfvars file by taking the reference from example.tfvars file

## init
  `terraform init`
## plan
  `terraform plan`
## apply
```terraform apply```

