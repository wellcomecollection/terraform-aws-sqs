locals {
  max_age_in_seconds = var.max_age_in_hours * 3600

  # Allows for deprecation of alarm_topic_arn in favor of dlq_alarm_topic_arn
  # An empty string means no topic, as null does
  alarm_topic_arn_safe  = var.alarm_topic_arn != null && var.alarm_topic_arn != "" ? [var.alarm_topic_arn] : []
  dlq_alarm_action_arns = var.dlq_alarm_action_arns != [] ? var.dlq_alarm_action_arns : local.alarm_topic_arn_safe

  enable_dlq_not_empty_alarm = var.enable_dlq_not_empty_alarm || local.dlq_alarm_action_arns != []
  # An age alarm with no action tells nobody, so it is only created when it has one
  enable_queue_age_alarm = length(var.main_q_age_alarm_action_arns) > 0

  # Tags and a description prefix that tie each alarm to its Backplane Component
  alarm_identity_tags = merge(
    var.alarm_tags,
    var.alarm_component == null ? {} : { "backplane:component" = var.alarm_component },
    var.alarm_repository == null ? {} : { "github.com/project-slug" = var.alarm_repository },
  )

  dlq_alarm_description_base = coalesce(var.dlq_alarm_description, "Alarm if the DLQ is not empty")
  age_alarm_description_base = "Message age exceeds ${var.max_age_in_hours} hours"

  dlq_alarm_description = var.alarm_component == null ? local.dlq_alarm_description_base : "[component=${var.alarm_component} severity=${var.dlq_alarm_severity}] ${local.dlq_alarm_description_base}"
  age_alarm_description = var.alarm_component == null ? local.age_alarm_description_base : "[component=${var.alarm_component} severity=${var.age_alarm_severity}] ${local.age_alarm_description_base}"
}

resource "aws_cloudwatch_metric_alarm" "dlq_not_empty" {
  count = local.enable_dlq_not_empty_alarm == true ? 1 : 0

  alarm_name          = "${aws_sqs_queue.dlq.name}_not_empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  threshold           = 0
  statistic           = "Average"

  alarm_description = local.dlq_alarm_description

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }

  alarm_actions = local.dlq_alarm_action_arns

  tags = merge(local.alarm_identity_tags, { severity = var.dlq_alarm_severity })
}

resource "aws_cloudwatch_metric_alarm" "queue_age" {
  count = local.enable_queue_age_alarm == true ? 1 : 0

  alarm_name          = "${aws_sqs_queue.q.name}_age"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  threshold           = local.max_age_in_seconds
  statistic           = "Maximum"

  alarm_description = local.age_alarm_description

  dimensions = {
    QueueName = aws_sqs_queue.q.name
  }

  alarm_actions = var.main_q_age_alarm_action_arns

  tags = merge(local.alarm_identity_tags, { severity = var.age_alarm_severity })
}
