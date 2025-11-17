variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "parameters" {
  description = "Map of SSM parameters to create"
  type = map(object({
    name        = string
    value       = string
    type        = optional(string)        # String, StringList, or SecureString
    description = optional(string)
    tier        = optional(string)        # Standard or Advanced
    overwrite   = optional(bool)
    tags        = optional(map(string))
  }))
  default = {}
}

variable "create_kms_key" {
  description = "Create a KMS key for encrypting SecureString parameters"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encrypting SecureString parameters (if not creating one)"
  type        = string
  default     = null
}

variable "create_access_policy" {
  description = "Create an IAM policy for accessing SSM parameters"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
