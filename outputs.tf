output "ssh_connection_string_for_jenkins_master_server" {
  value = module.jenkins.ssh_connection_string_for_ec2
}

output "ssh_connection_string_for_jenkins_slave_server" {
  value = module.jenkins.ssh_connection_string_for_slave
}

output "ssh_connection_string_for_node_server" {
  value = module.node_server.ssh_connection_string_for_node_server
}

output "docker_pull_command" {
  value = module.container_registry.node_service_image_url
}
