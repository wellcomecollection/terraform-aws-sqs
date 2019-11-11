resource "aws_sns_topic_subscription" "sns_topic" {
  count     = length(var.topic_arns)
  topic_arn = element(var.topic_arns, count.index)
  endpoint  = aws_sqs_queue.q.arn
  protocol  = "sqs"
}

