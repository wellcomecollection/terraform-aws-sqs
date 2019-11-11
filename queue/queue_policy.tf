data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "write_to_queue" {
  statement {
    sid    = "es-sns-to-sqs-policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      # We construct this ARN manually because this policy document is an input
      # to the aws_sqs_queue resource.
      #
      # We can't get the ARN from that until it's been created, so this document
      # can't rely on the queue -- that would create a circular reference.
      "arn:aws:sqs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.queue_name}",
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = var.topic_arns
    }
  }
}

data "aws_iam_policy_document" "read_from_queue" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
    ]

    resources = [
      aws_sqs_queue.q.arn,
    ]
  }
}

