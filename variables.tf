variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "max_capacity" {
  type        = number
  description = "Maximum number of running instances of a Service"
  default     = 10
}

variable "min_capacity" {
  type        = number
  description = "Minimum number of running instances of a Service"
  default     = 1
}

variable "schedule" {
  type = list(object({
    schedule     = string
    min_capacity = number
    max_capacity = number
  }))
  description = "Provides an Application AutoScaling ScheduledAction resource"
  default     = []
}

variable "service_name" {
  type        = string
  description = "Name of the ECS Service"
}

variable "target_tracking" {
  type = list(object({
    target_value       = number
    scale_in_cooldown  = number
    scale_out_cooldown = number
    predefined_metric_specification = list(object({
      predefined_metric_type = string
      resource_label         = optional(string)
    }))
    customized_metric_specification = list(object({
      metric_name = string
      namespace   = string
      statistic   = string
      unit        = string
    }))
  }))
  description = "Provides an Application AutoScaling Policy resource"
  default     = []
}
