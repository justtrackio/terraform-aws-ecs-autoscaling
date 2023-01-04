resource "aws_appautoscaling_target" "default" {
  count              = module.this.enabled ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  role_arn           = "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "default" {
  count              = module.this.enabled && length(var.schedule) == 0 ? 1 : 0
  name               = module.this.id
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.default[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.default[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.default[count.index].service_namespace

  dynamic "target_tracking_scaling_policy_configuration" {
    for_each = var.target_tracking
    content {
      dynamic "predefined_metric_specification" {
        for_each = lookup(target_tracking_scaling_policy_configuration.value, "predefined_metric_specification", [])
        content {
          predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
          resource_label         = lookup(predefined_metric_specification.value, "resource_label", null)
        }
      }

      dynamic "customized_metric_specification" {
        for_each = lookup(target_tracking_scaling_policy_configuration.value, "customized_metric_specification", [])
        content {
          metric_name = customized_metric_specification.value.metric_name
          namespace   = lookup(customized_metric_specification.value, "namespace", null)
          statistic   = lookup(customized_metric_specification.value, "statistic", null)
          unit        = lookup(customized_metric_specification.value, "unit", null)
        }
      }

      target_value       = target_tracking_scaling_policy_configuration.value.target_value
      scale_in_cooldown  = lookup(target_tracking_scaling_policy_configuration.value, "scale_in_cooldown", null)
      scale_out_cooldown = lookup(target_tracking_scaling_policy_configuration.value, "scale_out_cooldown", null)
    }
  }
}

resource "aws_appautoscaling_scheduled_action" "schedule" {
  count              = module.this.enabled && length(var.schedule) > 0 ? length(var.schedule) : 0
  name               = "${module.this.id}-${count.index}"
  resource_id        = aws_appautoscaling_target.default[0].resource_id
  scalable_dimension = aws_appautoscaling_target.default[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.default[0].service_namespace

  schedule = lookup(var.schedule[count.index], "schedule")

  scalable_target_action {
    min_capacity = lookup(var.schedule[count.index], "min_capacity")
    max_capacity = lookup(var.schedule[count.index], "max_capacity")
  }
}
