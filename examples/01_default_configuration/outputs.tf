output "sns_topic_arn" {
  description = "The ARN of the SNS topic."
  value       = module.fsx_monitor.sns_topic_arn
}

output "role_arn" {
  description = "The ARN of the IAM role."
  value       = module.fsx_monitor.role_arn
}

output "cloudwatch_alert_arns" {
  description = "A map of consisting of FSx filesystem identifiers and their CloudWatch metric alarm ARNs."
  value       = module.fsx_monitor.cloudwatch_metric_alarm_arns
}
