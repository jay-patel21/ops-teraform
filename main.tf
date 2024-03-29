
module "security_groups" {
  source              = "./security-groups"
  ec2_sg_name         = "SG for EC2 to enable SSH(22), HTTPS(443) and HTTP(80)"
  ec2_jenkins_master_sg_name = "Allow port 8080 for jenkins"
  ec2_jenkins_slave_sg_name = "publish remote ip for slave"
  ec2_node_server_sg_name = "Allow port 3000 for backend node server"
  jenkins_master_public_id = [format("%s%s",module.jenkins.jenkins_master_public_ip,"/32")]
}

module "jenkins" {
  source = "./jenkins"
  master_public_key = var.public_key_jenkins_master
  slave_public_key = var.public_key_jenkins_slave
  availability_zone = var.availability_zone
  security_groups_jenkins_master =  [module.security_groups.aws_security_group_id,module.security_groups.aws_security_group_jenkins_master_id]
  security_groups_jenkins_slave = [module.security_groups.aws_security_group_id,module.security_groups.aws_security_group_jenkins_slave_id]
  ami_id = var.ec2_ami_id
  instance_type = var.instance_type
  user_data = templatefile("./jenkins/userdata.sh",{})
  slave_user_data = templatefile("./jenkins/slave-setup.sh",{})
}


module "container_registry" {
  source = "./container-repo"
  repo_name = "node-service"
}

module "node_server" {
  source = "./node-server"
  ami_id = var.ec2_ami_id
  instance_type = var.instance_type
  security_groups_id = [module.security_groups.aws_security_group_id, module.security_groups.ec2_security_grouo_node_server_id]
  public_key = var.public_key_backend_service
  ecr_image = module.container_registry.node_service_image_url
  region = var.aws_region
}

