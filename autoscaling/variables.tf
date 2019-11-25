variable "queue_name" {}

variable "queue_low_actions" {
  type = list(string)
}

variable "queue_high_actions" {
  type = list(string)
}
