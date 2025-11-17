variable "application_name" {
  description = "Name of the CodeDeploy application"
  type        = string
}

variable "deployment_group_name" {
  description = "Name of the deployment group"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "ARN of the IAM role for CodeDeploy"
  type        = string
}

variable "deployment_config_name" {
  description = "Deployment configuration name (e.g., CodeDeployDefault.ECSAllAtOnce, CodeDeployDefault.ECSLinear10PercentEvery1Minutes)"
  type        = string
  default     = "CodeDeployDefault.ECSAllAtOnce"
}

variable "auto_rollback_enabled" {
  description = "Enable automatic rollback"
  type        = bool
  default     = true
}

variable "auto_rollback_events" {
  description = "Events that trigger automatic rollback"
  type        = list(string)
  default     = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
}

variable "deployment_ready_action" {
  description = "Action to take when deployment is ready (CONTINUE_DEPLOYMENT or STOP_DEPLOYMENT)"
  type        = string
  default     = "CONTINUE_DEPLOYMENT"
  validation {
    condition     = contains(["CONTINUE_DEPLOYMENT", "STOP_DEPLOYMENT"], var.deployment_ready_action)
    error_message = "deployment_ready_action must be either CONTINUE_DEPLOYMENT or STOP_DEPLOYMENT."
  }
}

variable "deployment_ready_wait_time" {
  description = "Wait time in minutes before stopping deployment (only if action is STOP_DEPLOYMENT)"
  type        = number
  default     = 0
}

variable "terminate_blue_action" {
  description = "Action to take after successful deployment (TERMINATE or KEEP_ALIVE)"
  type        = string
  default     = "TERMINATE"
  validation {
    condition     = contains(["TERMINATE", "KEEP_ALIVE"], var.terminate_blue_action)
    error_message = "terminate_blue_action must be either TERMINATE or KEEP_ALIVE."
  }
}

variable "termination_wait_time" {
  description = "Wait time in minutes before terminating blue instances"
  type        = number
  default     = 5
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "prod_listener_arns" {
  description = "ARNs of the production listener(s)"
  type        = list(string)
}

variable "test_listener_arns" {
  description = "ARNs of the test listener(s)"
  type        = list(string)
  default     = []
}

variable "blue_target_group_name" {
  description = "Name of the blue (production) target group"
  type        = string
}

variable "green_target_group_name" {
  description = "Name of the green target group"
  type        = string
}

variable "alarm_configuration" {
  description = "CloudWatch alarm configuration for automatic rollback"
  type = object({
    alarms                    = list(string)
    enabled                   = bool
    ignore_poll_alarm_failure = optional(bool)
  })
  default = {
    alarms                    = []
    enabled                   = false
    ignore_poll_alarm_failure = false
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
