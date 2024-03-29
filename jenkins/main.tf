variable "ami_id" {}
variable "master_public_key" {}
variable "slave_public_key" {}
variable "availability_zone" {}
variable "security_groups_jenkins_master" {}
variable "security_groups_jenkins_slave" {}
variable "instance_type" {}
variable "user_data" {}
variable "slave_user_data" {}



output "ssh_connection_string_for_ec2" {
  value = format("%s%s", "ssh -i ec2 ubuntu@", aws_instance.jenkins_master.public_ip)
}


output "ssh_connection_string_for_slave" {
  value = format("%s%s", "ssh -i ec2 ubuntu@", aws_instance.jenkins_slave.public_ip)
}
output "jenkins_master_public_ip" {
  value = aws_instance.jenkins_master.public_ip
}

resource "aws_instance" "jenkins_master" {
  ami = var.ami_id
  key_name = "jenkins_master"
  tags = {
    Name = "jenkins master"
  }
  vpc_security_group_ids = var.security_groups_jenkins_master
  instance_type = var.instance_type
  user_data = var.user_data
}

resource "aws_instance" "jenkins_slave" {
  ami = var.ami_id
  key_name = "jenkins_slave"
  tags = {
    Name = "jenkins slave"
  }
  vpc_security_group_ids = var.security_groups_jenkins_slave
  instance_type = var.instance_type
  user_data = var.slave_user_data
}


resource "aws_key_pair" "jenkins_ec2_master_public_key" {
  key_name   = "jenkins_master"
  public_key = var.master_public_key
}


resource "aws_key_pair" "jenkins_ec2_slave_public_key" {
  key_name   = "jenkins_slave"
  public_key = var.slave_public_key
}