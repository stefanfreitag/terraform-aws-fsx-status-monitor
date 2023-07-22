variable "email" {
  description = "List of e-mail addresses subscribing to the SNS topic. Default is empty list."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources. Default is empty map."
  type        = map(string)
  default = {
  }
}
