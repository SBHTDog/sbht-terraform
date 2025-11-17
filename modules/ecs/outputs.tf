output "cluster_id" {
  description = "The ECS cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "task_execution_role_arn" {
  description = "The ARN of the task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  description = "The ARN of the task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "task_definition_arn" {
  description = "The ARN of the task definition"
  value       = var.create_task_definition ? aws_ecs_task_definition.main[0].arn : null
}

output "service_id" {
  description = "The ID of the ECS service"
  value       = var.create_service ? aws_ecs_service.main[0].id : null
}

output "service_name" {
  description = "The name of the ECS service"
  value       = var.create_service ? aws_ecs_service.main[0].name : null
}

output "log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs.name
}
