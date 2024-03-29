variable "ec2_ami_id" {
  type        = string
  description = "DevOps Project 1 AMI Id for EC2 instance"
}

variable "public_key_jenkins_master" {
  type = string
  description = "public key for ssh in jenkins server"
}

variable "public_key_jenkins_slave" {
  type = string
  description = "public key for ssh in jenkins server"
}

variable "public_key_backend_service" {
  type = string
  description = "public key for ssh in backend with node js"
}


variable "availability_zone" {
  type = string
  description = "availibility zone for this infra"
}

variable "instance_type" {
  type = string
  description = "type of the instance"  
}

variable "aws_region" {
  type = string
  description = "region for aws"
}

variable "aws_credentials" {
  type = string
  description = "The credentials for the aws account"
  
}

