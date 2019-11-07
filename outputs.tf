output "url" {
  description = "URL for the new SQS queue"
  value       = aws_sqs_queue.q.id
}

output "arn" {
  description = "ARN of the new SQS queue"
  value       = aws_sqs_queue.q.arn
}

output "name" {
  description = "Name of the new SQS queue"
  value       = aws_sqs_queue.q.name
}

output "read_policy" {
  description = "Policy that allows reading from the created SQS queue"
  value       = data.aws_iam_policy_document.read_from_queue.json
}
