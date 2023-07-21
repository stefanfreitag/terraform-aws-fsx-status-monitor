variable "email" {
  description = "E-mail subscribing to the SNS topic."
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default = {
  }
}
