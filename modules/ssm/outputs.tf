output "parameter_arns" {
  description = "Map of parameter names to ARNs"
  value       = { for k, v in aws_ssm_parameter.main : k => v.arn }
}

output "parameter_names" {
  description = "Map of parameter keys to names"
  value       = { for k, v in aws_ssm_parameter.main : k => v.name }
}

output "kms_key_id" {
  description = "The ID of the KMS key (if created)"
  value       = var.create_kms_key ? aws_kms_key.ssm[0].id : null
}

output "kms_key_arn" {
  description = "The ARN of the KMS key (if created)"
  value       = var.create_kms_key ? aws_kms_key.ssm[0].arn : null
}

output "access_policy_arn" {
  description = "The ARN of the IAM access policy (if created)"
  value       = var.create_access_policy ? aws_iam_policy.ssm_access[0].arn : null
}
