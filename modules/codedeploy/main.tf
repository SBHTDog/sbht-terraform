# CodeDeploy Application
resource "aws_codedeploy_app" "this" {
  name             = var.application_name
  compute_platform = "ECS"

  tags = var.tags
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = var.deployment_group_name
  service_role_arn       = var.codedeploy_role_arn
  deployment_config_name = var.deployment_config_name

  auto_rollback_configuration {
    enabled = var.auto_rollback_enabled
    events  = var.auto_rollback_events
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = var.deployment_ready_action
      wait_time_in_minutes = var.deployment_ready_action == "STOP_DEPLOYMENT" ? var.deployment_ready_wait_time : null
    }

    terminate_blue_instances_on_deployment_success {
      action                           = var.terminate_blue_action
      termination_wait_time_in_minutes = var.termination_wait_time
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = var.prod_listener_arns
      }

      dynamic "test_traffic_route" {
        for_each = length(var.test_listener_arns) > 0 ? [1] : []
        content {
          listener_arns = var.test_listener_arns
        }
      }

      target_group {
        name = var.blue_target_group_name
      }

      target_group {
        name = var.green_target_group_name
      }
    }
  }

  # Optional: CloudWatch Alarms for automatic rollback
  dynamic "alarm_configuration" {
    for_each = length(var.alarm_configuration) > 0 ? [var.alarm_configuration] : []
    content {
      alarms                    = alarm_configuration.value.alarms
      enabled                   = alarm_configuration.value.enabled
      ignore_poll_alarm_failure = lookup(alarm_configuration.value, "ignore_poll_alarm_failure", false)
    }
  }

  tags = var.tags
}
