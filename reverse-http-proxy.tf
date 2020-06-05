resource "aws_alb" "core" {
  name            = "${var.application_name}-alb${var.env == "master" ? "" : "-${var.env}"}"
  subnets         = var.subnet_ids
  security_groups = [aws_security_group.core_alb.id]

  access_logs {
    bucket  = var.artifact_bucket
    prefix  = "${var.application_name}-alb${var.env == "master" ? "" : "-${var.env}"}"
    enabled = true
  }

  tags = var.tags
}

resource "aws_alb_target_group" "core" {
  name        = "${var.application_name}-target${var.env == "master" ? "" : "-${var.env}"}"
  port        = var.internal_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  slow_start  = 30
  tags        = var.tags

  health_check {
    interval            = 10
    path                = var.health_endpoint
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 6
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"

  }
}

resource "aws_alb_listener" "core" {
  load_balancer_arn = aws_alb.core.id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.cert_arn

  // It is possible to route back default responses. If we need them, define them here below.
  default_action {
    target_group_arn = aws_alb_target_group.core.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "http_redirect" {
  load_balancer_arn = aws_alb.core.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
