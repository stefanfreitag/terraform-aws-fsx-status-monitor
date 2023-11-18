run "eventbridge_default_schedule_expression" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.fsx_health_lambda_schedule.schedule_expression == "rate(5 minutes)"
    error_message = "Schedule expression is not matching expected value of rate(5 minutes)"
  }
}

##
# The default value for CloudWatch Alarm property treat_missing_data should be set to breaching.
##
run "aws_cloudwatch_metric_alarm_default_treat_missing_data" {
  command = plan
  variables {
    filesystem_ids                         = ["fs-01234567890123456"]
    enable_cloudwatch_alarms             = true
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.this["fs-01234567890123456"].treat_missing_data == "breaching"
    error_message = "The default value for treat_missing_data is not set to breaching."
  }
}
