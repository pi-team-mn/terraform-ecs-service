resource "aws_security_group" "core_alb" {
  name        = "${var.application_name}-sg-alb${var.env == "master" ? "" : "-${var.env}"}"
  description = "${var.application_name}-${var.env} ALB Firewalling"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress {
    protocol    = "tcp"
    from_port   = var.external_port
    to_port     = var.external_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = var.internal_port
    to_port     = var.internal_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "core_ecs_tasks" {
  name        = "${var.application_name}-sg-ecs-tasks${var.env == "master" ? "" : "-${var.env}"}"
  description = "${var.application_name}-${var.env} Application Firewalling"
  vpc_id      = var.vpc_id
  tags        = var.tags
  ingress {
    protocol        = "tcp"
    from_port       = var.internal_port
    to_port         = var.internal_port
    security_groups = [aws_security_group.core_alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
