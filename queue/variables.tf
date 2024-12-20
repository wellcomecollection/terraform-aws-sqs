variable "queue_name" {
  description = "Name of the SQS queue to create"
}

variable "topic_arns" {
  type        = list(string)
  description = "ARNs for the SNS topics to subscribe the queue to"
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue"
  default     = 30
}

variable "message_retention_seconds" {
  description = "The number of seconds that SQS retains a message"
  default     = 345600
}

variable "max_message_size" {
  description = "Maximum message size allowed by SQS, in bytes"
  default     = 262144
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed"
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning"
  default     = 0
}

variable "max_receive_count" {
  description = "Max receive count before sending to DLQ"
  default     = 4
}

variable "alarm_topic_arn" {
  description = "DEPRECATED, use dlq_alarm_topic_arn: ARN of the topic where to send notification for DLQs not being empty. If null, no alarm will be created."
  default     = null
}

variable "enable_dlq_not_empty_alarm" {
  description = "Enable alarm for DLQs not being empty"
  default     = false
}

variable "enable_queue_age_alarm" {
  description = "Enable alarm for messages exceeding max_age_in_hours"
  default     = false
}

variable "dlq_alarm_action_arns" {
  description = "ARNs for the topics where to send notification for DLQs not being empty, if not empty overrides alarm_topic_arn."
  default     = []
}

variable "main_q_age_alarm_action_arns" {
  description = "ARN for the topics where to send notification for messages exceeding max_age_in_hours, if not empty overrides enable_queue_age_alarm."
  default     = []
}

variable "max_age_in_hours" {
  description = "The maximum age of a message in hours"
  type        = number
  default     = 6
}

variable "fifo_queue" {
  description = "Boolean designating a FIFO queue"
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues"
  default     = false
}
