variable "ec2_sg_name" {}
variable "ec2_jenkins_master_sg_name" {}
variable "ec2_jenkins_slave_sg_name" {}
variable "ec2_node_server_sg_name" {}
variable "jenkins_master_public_id" {}

output "aws_security_group_id" {
  value = aws_security_group.sg_for_ssh.id
}

output "aws_security_group_jenkins_master_id" {
    value = aws_security_group.jenkins_master.id
}

output "aws_security_group_jenkins_slave_id" {
    value = aws_security_group.jenkins_slave.id
}

output "ec2_security_grouo_node_server_id" {
    value = aws_security_group.node_server.id
  
}

resource "aws_security_group" "sg_for_ssh" {
    name = var.ec2_sg_name
    description = "Security group which allow ssh"
    # vpc_id = var.vpc_id
    ingress {
    description = "Allow HTTPs request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    }

    ingress {
        description = "Allow htttp request from anywhere"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 80
        to_port = 80
        protocol = "tcp"
    }

    ingress {
        description = "allow ssh from anywhere"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 22
        to_port = 22
        protocol = "tcp"
    }

    egress {
        description = "allow make out side request to anywhere"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 0
        protocol = "-1"
    }

}


resource "aws_security_group" "jenkins_master" {
    name = var.ec2_jenkins_master_sg_name
    description = "to make port 8080 accessible"

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 8080
        to_port = 8080
        description = "allow traffic from 8080 port from anywhere"
        protocol = "tcp"
    }
  
}


//TODO: We can add it into the private subnet
resource "aws_security_group" "jenkins_slave" {
    name = var.ec2_jenkins_slave_sg_name
    description = "to expose jenkins slave to the master"

    ingress {
        cidr_blocks = var.jenkins_master_public_id
        from_port = 4243
        to_port = 4243
        description = "allow traffic from 4243 port from jenkins master only"
        protocol = "tcp"
    }

    ingress {
        cidr_blocks = var.jenkins_master_public_id
        from_port = 32768
        to_port = 60999
        description = "allow traffic from range of port between 32768 and 60999 from jenkins master only"
        protocol = "tcp"
    }
  
}

resource "aws_security_group" "node_server" {
   name = var.ec2_node_server_sg_name
   description = "alllowing inbound traffiv from port 3000"

   ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 3000
    to_port = 3000
    description = "enable port 3000"
    protocol = "tcp"
   }
}