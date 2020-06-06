resource "aws_ecs_service" "core" {
  name            = "${var.application_name}-service${var.env == "master" ? "" : "-${var.env}"}"
  cluster         = data.aws_ecs_cluster.generic.id
  task_definition = var.task_definition_arn
  desired_count   = var.scaling_desired
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.core_ecs_tasks.id]
    subnets         = var.service_subnet_ids
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.core.id
    container_name   = "${var.application_name}${var.env == "master" ? "" : "-${var.env}"}"
    container_port   = var.internal_port
  }

  depends_on = [
    aws_alb_listener.core,
  ]

  lifecycle {
    ignore_changes = [desired_count] // when deploying ignore changes to a scaled up or down service
  }
}

resource "aws_appautoscaling_target" "core" {
  max_capacity       = var.scaling_max
  min_capacity       = var.scaling_min
  resource_id        = "service/generic-ecs/${aws_ecs_service.core.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "quick-horizontal-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.core.resource_id
  scalable_dimension = aws_appautoscaling_target.core.scalable_dimension
  service_namespace  = aws_appautoscaling_target.core.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
      // "ALBRequestCountPerTarget" //ECSServiceAverageMemoryUtilization //ECSServiceAverageCPUUtilization
      // resource label for ALBRequestCountPerTarget
      // app/<load-balancer-name>/<load-balancer-id>/targetgroup/<target-group-name>/<target-group-id>
    }

    target_value       = 75
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    disable_scale_in = false
  }
}
