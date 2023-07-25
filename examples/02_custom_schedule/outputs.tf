output "sns_topic_arn" {
  description = "The ARN of the SNS topic."
  value       = module.fsx_monitor.sns_topic_arn
}

output "role_arn" {
  description = "The ARN of the IAM role."
  value       = module.fsx_monitor.role_arn
}
