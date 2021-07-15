# terraform-aws-sqs

[![Build status](https://badge.buildkite.com/195ef4c9dc2d8d747956a9eaa282ceeb01d5bb9c26d13aefba.svg?main)](https://buildkite.com/wellcomecollection/terraform-module-terraform-aws-sqs)
This module allows you to create an SQS queue with all the trimmings.

That includes:

*   An SQS queue
*   A dead letter queue (DLQ), which receives any failed messages from the original queue
*   A CloudWatch alarm that raises when there are messages on the DLQ
*   An IAM policy that lets you read from the queue
*   Subscriptions from SNS topics to the queue

You can also use the `autoscaling` module to trigger actions based on the size of the queue.


## Usage

Here's an example of how to use the module:

```hcl
module "queue" {
  source = "git::github.com/wellcomecollection/terraform-aws-sqs//queue?ref=v1.1.0"

  # Name of the new queue
  queue_name = "my_first_queue"

  # SNS topics to subscribe to
  topic_arns = [
    aws_sns_topic.subscription_topic.arn
  ]

  # SNS topic to send DLQ notifications to
  alarm_topic_arn = aws_sns_topic.alarm_topic_arn.arn

  # How many times a message should be received, and never deleted, before
  # it gets marked as "failed" and sent to the DLQ.
  max_receive_count = 3

  # Make this a FIFO queue
  fifo_queue = true

  # Enable content-based deduplication for FIFO queues
  content_based_deduplication = true

  # These are required for constructing some of the fiddly IAM bits
  aws_region = "eu-west-1"
}
```


## Outputs

The module exports the following attributes:

*   `url` - URL of the new queue
*   `arn` - ARN of the new queue
*   `name` - Name of the new queue
*   `read_policy` - JSON for an IAM policy that allows reading from the queue
