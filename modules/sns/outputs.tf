output "topic_arn" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.main.arn
}

output "topic_id" {
  description = "The ID of the SNS topic"
  value       = aws_sns_topic.main.id
}

output "topic_name" {
  description = "The name of the SNS topic"
  value       = aws_sns_topic.main.name
}

output "subscription_arns" {
  description = "List of ARNs of the topic subscriptions"
  value       = aws_sns_topic_subscription.main[*].arn
}
