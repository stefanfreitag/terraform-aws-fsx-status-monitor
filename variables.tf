variable "enable_cloudwatch_alarms" {
  description = "Setup CloudWatch alarms for the FSx filesystem state. For each state a separate alarm will be created. Default is false."
  type        = bool
  default     = false
}

variable "cloudwatch_alarms_treat_missing_data" {
  description = "Sets how the alarms handle missing data points. The following values are supported: `missing`, `ignore`, `breaching` and `notBreaching`. Default is `breaching`."
  type        = string
  default     = "breaching"
  validation {
    condition     = can(regex("^(missing|ignore|breaching|notBreaching)$", var.cloudwatch_alarms_treat_missing_data))
    error_message = "The value must be one of missing, ignore, breaching or notBreaching."
  }
}

variable "alarm_actions" {
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). Default is `null`."
  type        = list(string)
  default     = null
}

variable "insufficient_data_actions" {
  description = "The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN). Default is `null`."
  type        = list(string)
  default     = null
}

variable "ok_actions" {
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). Default is `null`"
  type        = list(string)
  default     = null
}

variable "filesystem_ids" {
  description = "List of filesystem identifiers. Default is empty list."
  type        = list(string)
  default     = []
}

variable "ignore_states" {
  description = "Suppress warnings for the listed FSx states. Default: ['CREATING', 'UPDATING']"
  type        = list(string)
  default = [
    "CREATING", "UPDATING"
  ]
  validation {
    condition     = alltrue([for state in var.ignore_states : contains(["AVAILABLE", "CREATING", "MISCONFIGURED", "MISCONFIGURED_UNAVAILABLE", "UPDATING", "DELETING", "FAILED"], state)])
    error_message = "value"
  }
}

variable "lambda_insights_layers_arn" {
  description = "The ARN of the Lambda Insights layer. Default is `null`."
  type        = string
  default     = null
}

variable "log_retion_period_in_days" {
  type        = number
  default     = 365
  description = "Number of days logs will be retained. Default is 365 days."

  validation {
    condition = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
    400, 545, 731, 1096, 1827, 2192, 2557, 2992, 3288, 3653], var.log_retion_period_in_days)
    error_message = "log_retion_period_in_days must be one of the allowed values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653"
  }
}

variable "name" {
  type        = string
  description = "Name of the health monitor. Default is `fsx_status_monitor`."
  default     = "fsx_status_monitor"
}


variable "memory_size" {
  type        = number
  description = "Amount of memory in MByte that the Lambda Function can use at runtime. Default is 160."
  default     = 160
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "memory_size must be between 128 and 10240"
  }
}

variable "schedule_expression" {
  description = "The schedule expression for the CloudWatch event rule. Default is 'rate(5 minutes)'."
  type        = string
  default     = "rate(5 minutes)"
}

variable "tags" {
  description = "A map of tags to add to all resources. Default is empty map."
  type        = map(string)
  default = {
  }
}

variable "timeout" {
  type        = number
  description = "The amount of time that Lambda allows a function to run before stopping it. Default is 30 seconds."
  default     = 30
  validation {
    condition     = var.timeout >= 10 && var.timeout <= 900
    error_message = "Timeout must be between 10 and 900."
  }
}
