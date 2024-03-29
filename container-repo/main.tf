
variable "repo_name" {}


output "node_service_image_url" {
  value = format("%s", aws_ecr_repository.node_service.repository_url)
}

resource "aws_ecr_repository" "node_service" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
