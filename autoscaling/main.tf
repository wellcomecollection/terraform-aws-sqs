resource "aws_cloudwatch_metric_alarm" "queue_high" {
  alarm_name          = "${var.queue_name}_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  alarm_description   = "Queue high"

  alarm_actions = var.queue_high_actions

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"
  period      = "60"

  statistic = "Sum"

  dimensions = {
    QueueName = var.queue_name
  }

  insufficient_data_actions = []
}

locals {
  cooldown_period_map = {
    "1m" : 60,
    "15m" : 60 * 15,
  }

  queue_low_period = local.cooldown_period_map[var.cooldown_period]
}

resource "aws_cloudwatch_metric_alarm" "queue_low" {
  alarm_name          = "${var.queue_name}_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  threshold           = 1
  alarm_description   = "Queue low"

  alarm_actions = var.queue_low_actions

  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "m1+m2+m3"
    label       = "ApproximateNumberOfMessagesTotal"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = local.queue_low_period
      stat        = "Sum"

      dimensions = {
        QueueName = var.queue_name
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "ApproximateNumberOfMessagesNotVisible"
      namespace   = "AWS/SQS"
      period      = local.queue_low_period
      stat        = "Sum"

      dimensions = {
        QueueName = var.queue_name
      }
    }
  }

  metric_query {
    id = "m3"

    metric {
      metric_name = "NumberOfMessagesDeleted"
      namespace   = "AWS/SQS"
      period      = local.queue_low_period
      stat        = "Sum"

      dimensions = {
        QueueName = var.queue_name
      }
    }
  }
}
