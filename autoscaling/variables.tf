variable "queue_name" {}

variable "queue_low_actions" {
  type = list(string)
}

variable "queue_high_actions" {
  type = list(string)
}

# If a queue hasn't received messages for six hours or more, CloudWatch
# considers the queue to be inactive.  When a queue is activated from an
# inactive state, there can be a delay of up to 15 minutes in receiving
# queue metrics.
#
# This can manifest as the "scale down" alarm triggering too quickly, and
# scaling down an app while it still has in-flight work.  This is more of
# a problem for some apps than others -- in the catalogue pipeline where
# work is processed quickly, it may complete before the app gets scaled
# down.  It's more of a problem in the storage service, where a single
# bit of work may take hours to complete.
#
# See https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-monitoring-using-cloudwatch.html
#
variable "cooldown_period" {
  description = "How many minutes to wait for updated SQS metrics before scaling down tasks"
  default     = "1m"

  validation {
    condition = contains(["1m", "15m"], var.cooldown_period)
    error_message = "Cooldown period should be either 1 minute or 15 minutes."
  }
}
