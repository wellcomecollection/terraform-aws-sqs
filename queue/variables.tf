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
  description = "DEPRECATED, has no effect: the age alarm is created when main_q_age_alarm_action_arns is not empty, because an alarm with no action tells nobody."
  default     = false
}

variable "dlq_alarm_action_arns" {
  description = "ARNs for the topics where to send notification for DLQs not being empty, if not empty overrides alarm_topic_arn."
  default     = []
}

variable "main_q_age_alarm_action_arns" {
  description = "ARNs for the topics where to send notification for messages exceeding max_age_in_hours. The age alarm is only created when this is not empty."
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

variable "alarm_component" {
  description = "Name of the Backplane Component the alarms belong to (metadata.name in the repository's manifest.yml). Sets the backplane:component tag and the description prefix."
  type        = string
  default     = null
}

variable "alarm_repository" {
  description = "Owning repository as owner/name, for the github.com/project-slug tag."
  type        = string
  default     = null

  validation {
    condition     = var.alarm_repository == null || can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.alarm_repository))
    error_message = "alarm_repository must look like owner/name."
  }
}

variable "dlq_alarm_severity" {
  description = "Severity of the DLQ alarm: high, medium or low."
  type        = string
  default     = "medium"

  validation {
    condition     = contains(["high", "medium", "low"], var.dlq_alarm_severity)
    error_message = "dlq_alarm_severity must be high, medium or low."
  }
}

variable "age_alarm_severity" {
  description = "Severity of the queue age alarm: high, medium or low."
  type        = string
  default     = "low"

  validation {
    condition     = contains(["high", "medium", "low"], var.age_alarm_severity)
    error_message = "age_alarm_severity must be high, medium or low."
  }
}

variable "alarm_tags" {
  description = "Extra tags for the alarms."
  type        = map(string)
  default     = {}
}

variable "dlq_alarm_description" {
  type        = string
  default     = null
  description = "Description for the DLQ alarm, for example why it has no action"
}
