
variable "ami_id" {}
variable "public_key" {}
variable "security_groups_id" {}
variable "instance_type" {}
variable "ecr_image" {}


output "ssh_connection_string_for_node_server" {
  value = format("%s%s", "ssh -i node-server ubuntu@", aws_instance.node_server.public_ip)
}


resource "aws_instance" "node_server" {
  ami      = var.ami_id
  key_name = "node-server"
  tags = {
    Name = "node-server"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../scripts/aws-cli-install.sh",
      "${path.module}/../scripts/docker-install.sh",
    "${path.module}/../scripts/docker-compose-install.sh"]
  }


  provisioner "file" {
    source      = "~/.aws"
    destination = "/home/ubuntu/.aws"
  }


  provisioner "file" {
    source      = "${path.module}/setup/docker-compose.traefik.yml"
    destination = "/home/ubuntu/docker-compose.traefik.yml"
  }

  provisioner "file" {
    source      = "${path.module}/setup/traefik.yml"
    destination = "/home/ubuntu/traefik.yml"
  }

  provisioner "file" {
    source    = "${path.module}/setup/blue-green-deploy.sh"
    destination = "/home/ubuntu/blue-green-deploy.sh"
  }


  provisioner "file" {
    content     = templatefile("${path.module}/setup/node-service-docker-compose.yml", { ecr_image_url = var.ecr_image })
    destination = "/home/ubuntu/node-service-docker-compose.yml"
  }


  vpc_security_group_ids = var.security_groups_id
  instance_type          = var.instance_type

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/node_server")
    host        = self.public_ip
  }
}


resource "aws_key_pair" "node_server_key_pair" {
  key_name   = "node-server"
  public_key = var.public_key
}
