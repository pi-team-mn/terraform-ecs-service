data "aws_caller_identity" "current" {}

data "aws_route53_zone" "selected" {
  name         = "${var.domain_name}."
  private_zone = false
}

data "aws_ecs_cluster" "generic" {
  cluster_name = var.cluster_name
}
