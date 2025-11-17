output "application_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.this.name
}

output "application_id" {
  description = "ID of the CodeDeploy application"
  value       = aws_codedeploy_app.this.id
}

output "deployment_group_name" {
  description = "Name of the deployment group"
  value       = aws_codedeploy_deployment_group.this.deployment_group_name
}

output "deployment_group_id" {
  description = "ID of the deployment group"
  value       = aws_codedeploy_deployment_group.this.id
}

output "deployment_group_arn" {
  description = "ARN of the deployment group"
  value       = aws_codedeploy_deployment_group.this.arn
}
