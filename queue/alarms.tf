locals {
  max_age_in_seconds = var.max_age_in_hours * 3600

  # Allows for deprecation of alarm_topic_arn in favor of dlq_alarm_topic_arn
  alarm_topic_arn_safe = var.alarm_topic_arn != null ? [var.alarm_topic_arn] : []
  dlq_alarm_action_arns = var.dlq_alarm_action_arns != [] ? var.dlq_alarm_action_arns : local.alarm_topic_arn_safe

  # Name suffix allows for EventBridge rules to pick up alarms using wildcard
  queue_age_alarm_name_suffix     = var.queue_age_alarm_name_suffix != null ? "_${var.queue_age_alarm_name_suffix}" : ""
  dlq_not_empty_alarm_name_suffix = var.dlq_not_empty_alarm_name_suffix != null ? "_${var.dlq_not_empty_alarm_name_suffix}" : ""

  enable_dlq_not_empty_alarm = var.enable_dlq_not_empty_alarm || local.dlq_alarm_action_arns != []
  enable_queue_age_alarm     = var.enable_queue_age_alarm && var.main_q_age_alarm_action_arns != []
}

resource "aws_cloudwatch_metric_alarm" "dlq_not_empty" {
  count = local.enable_dlq_not_empty_alarm ? 1 : 0

  alarm_name          = "${aws_sqs_queue.dlq.name}_not_empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  threshold           = 0
  statistic           = "Average"

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }

  alarm_actions = local.dlq_alarm_action_arns
}

resource "aws_cloudwatch_metric_alarm" "queue_age" {
  count = local.enable_queue_age_alarm ? 1 : 0

  alarm_name          = "${aws_sqs_queue.q.name}_age${local.queue_age_alarm_name_suffix}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  threshold           = local.max_age_in_seconds
  statistic           = "Maximum"

  dimensions = {
    QueueName = aws_sqs_queue.q.name
  }

  alarm_actions = var.main_q_age_alarm_action_arns
}