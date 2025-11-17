variable "create_codedeploy_role" {
  description = "Whether to create CodeDeploy IAM role"
  type        = bool
  default     = true
}

variable "codedeploy_role_name" {
  description = "Name of the CodeDeploy IAM role"
  type        = string
  default     = "CodeDeployRoleForECS"
}

variable "create_github_oidc_provider" {
  description = "Whether to create GitHub OIDC provider"
  type        = bool
  default     = true
}

variable "github_oidc_provider_arn" {
  description = "ARN of existing GitHub OIDC provider (if not creating new one)"
  type        = string
  default     = null
}

variable "create_github_actions_role" {
  description = "Whether to create GitHub Actions IAM role"
  type        = bool
  default     = true
}

variable "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  type        = string
  default     = "GitHubActionsRole"
}

variable "github_repo" {
  description = "GitHub repository in format 'owner/repo'"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role (for PassRole permission)"
  type        = string
  default     = null
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role (for PassRole permission)"
  type        = string
  default     = null
}

variable "enable_s3_access" {
  description = "Enable S3 access for GitHub Actions"
  type        = bool
  default     = false
}

variable "s3_bucket_arns" {
  description = "ARNs of S3 buckets to grant access to"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
