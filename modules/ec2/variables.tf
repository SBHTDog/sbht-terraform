variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # 2vCPU, 1GB Mem, Free Tier Eligible
}

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
  default     = "ami-0a71e3eb8b23101ed" # Ubuntu Server 24.04 LTS, x86, Free Tier eligible
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "terraform_study"
}

variable "subnet_id" {
  description = "Subnet ID where instance will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of Security Group IDs"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to attach to the instance"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Whether to replace instance when user_data changes"
  type        = bool
  default     = false
}

variable "root_volume_type" {
  description = "Type of root volume (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 20
}

variable "root_delete_on_termination" {
  description = "Whether to delete root volume on instance termination"
  type        = bool
  default     = true
}

variable "root_volume_encrypted" {
  description = "Whether to encrypt the root volume"
  type        = bool
  default     = true
}

variable "root_volume_kms_key_id" {
  description = "KMS key ID for root volume encryption"
  type        = string
  default     = null
}

variable "metadata_http_tokens" {
  description = "Whether the metadata service requires session tokens (IMDSv2)"
  type        = string
  default     = "required" # Best practice: require IMDSv2
}

variable "metadata_http_put_response_hop_limit" {
  description = "Desired HTTP PUT response hop limit for instance metadata requests"
  type        = number
  default     = 1
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring (additional cost)"
  type        = bool
  default     = false
}

variable "disable_api_termination" {
  description = "Enable EC2 Instance Termination Protection"
  type        = bool
  default     = false
}

variable "disable_api_stop" {
  description = "Enable EC2 Instance Stop Protection"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}