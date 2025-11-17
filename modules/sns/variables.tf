variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "display_name" {
  description = "Display name for the SNS topic"
  type        = string
  default     = null
}

variable "fifo_topic" {
  description = "Whether the topic is FIFO"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO topics"
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "delivery_policy" {
  description = "SNS delivery policy"
  type        = string
  default     = null
}

variable "topic_policy" {
  description = "SNS topic policy"
  type        = string
  default     = null
}

variable "subscriptions" {
  description = "List of SNS topic subscriptions"
  type = list(object({
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = optional(bool)
    raw_message_delivery   = optional(bool)
    filter_policy          = optional(string)
    redrive_policy         = optional(string)
  }))
  default = []
}

variable "create_cloudwatch_alarms" {
  description = "Create CloudWatch alarms for the topic"
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
