provider "aws" {
  region  = "eu-west-1"
  version = "1.60.0"
}

resource "aws_sns_topic" "source_topic" {
  name = "tf_sqs_examples-source_topic"
}

resource "aws_sns_topic" "alarm_topic" {
  name = "tf_sqs_examples-alarm_topic"
}

module "queue" {
  source = "../queue"

  # Name of the new queue
  queue_name = "tf_sqs_examples-my_queue"

  # SNS topics to subscribe to
  topic_arns = [
    aws_sns_topic.source_topic.arn
  ]

  # SNS topic to send DLQ notifications to
  alarm_topic_arn = aws_sns_topic.alarm_topic_arn.arn

  # How many times a message should be received, and never deleted, before
  # it gets marked as "failed" and sent to the DLQ.
  max_receive_count = 3

  # These are required for constructing some of the fiddly IAM bits
  aws_region = "eu-west-1"
}
