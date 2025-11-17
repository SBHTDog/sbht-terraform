output "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy IAM role"
  value       = var.create_codedeploy_role ? aws_iam_role.codedeploy[0].arn : null
}

output "codedeploy_role_name" {
  description = "Name of the CodeDeploy IAM role"
  value       = var.create_codedeploy_role ? aws_iam_role.codedeploy[0].name : null
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : null
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = var.create_github_actions_role ? aws_iam_role.github_actions[0].arn : null
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = var.create_github_actions_role ? aws_iam_role.github_actions[0].name : null
}
