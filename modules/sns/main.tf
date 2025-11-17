# SNS Topic
resource "aws_sns_topic" "main" {
  name              = var.topic_name
  display_name      = var.display_name
  fifo_topic        = var.fifo_topic
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null

  kms_master_key_id = var.kms_master_key_id
  
  delivery_policy = var.delivery_policy

  tags = merge(
    var.tags,
    {
      Name = var.topic_name
    }
  )
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "main" {
  count  = var.topic_policy != null ? 1 : 0
  arn    = aws_sns_topic.main.arn
  policy = var.topic_policy
}

# SNS Topic Subscriptions
resource "aws_sns_topic_subscription" "main" {
  count     = length(var.subscriptions)
  topic_arn = aws_sns_topic.main.arn
  protocol  = var.subscriptions[count.index].protocol
  endpoint  = var.subscriptions[count.index].endpoint

  endpoint_auto_confirms = lookup(var.subscriptions[count.index], "endpoint_auto_confirms", false)
  raw_message_delivery   = lookup(var.subscriptions[count.index], "raw_message_delivery", false)
  
  filter_policy = lookup(var.subscriptions[count.index], "filter_policy", null)
  
  redrive_policy = lookup(var.subscriptions[count.index], "redrive_policy", null)
}

# CloudWatch Alarm for Failed Notifications (Best Practice)
resource "aws_cloudwatch_metric_alarm" "sns_failed_notifications" {
  count               = var.create_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${var.topic_name}-failed-notifications"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfNotificationsFailed"
  namespace           = "AWS/SNS"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors SNS failed notifications"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TopicName = aws_sns_topic.main.name
  }

  alarm_actions = var.alarm_actions

  tags = var.tags
}
