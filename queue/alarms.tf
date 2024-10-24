resource "aws_cloudwatch_metric_alarm" "dlq_not_empty" {
  count = var.alarm_topic_arn != null ? 1 : 0

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

  alarm_actions = [var.alarm_topic_arn]
}

