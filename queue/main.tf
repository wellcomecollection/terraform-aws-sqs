resource "aws_sqs_queue" "q" {
  name   = var.queue_name
  policy = data.aws_iam_policy_document.write_to_queue.json

  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  max_message_size            = var.max_message_size
  delay_seconds               = var.delay_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication

  redrive_policy = templatefile(
    "${path.module}/redrive_policy.json.tpl",
    {
      dlq_arn           = aws_sqs_queue.dlq.arn,
      max_receive_count = var.max_receive_count
    }
  )
}

resource "aws_sqs_queue" "dlq" {
  name = "${var.queue_name}_dlq"
}

