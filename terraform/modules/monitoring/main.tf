# SNS Topic
resource "aws_sns_topic" "this" {
  name = var.sns_topic_name
  tags = var.tags
}

# SNS Topic Subscriptions
resource "aws_sns_topic_subscription" "email" {
  count     = length(var.email_addresses)
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.email_addresses[count.index]
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = var.alarm_name
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold

  alarm_description   = <<EOT
ALERT: ${var.metric_name} exceeded threshold of ${var.threshold}.
Suggested actions: ${var.action_description}
EOT

  alarm_actions       = [aws_sns_topic.this.arn]

  dimensions          = var.dimensions
  tags                = var.tags
}

