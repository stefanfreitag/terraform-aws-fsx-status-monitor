run "aws_lambda_function_runtime_default" {
  command = plan

  assert {
    condition     = aws_lambda_function.fsx_health_lambda.runtime == "python3.12"
    error_message = "Lambda runtime is not Python 3.12."
  }
}

run "eventbridge_default_schedule_expression" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.fsx_health_lambda_schedule.schedule_expression == "rate(5 minutes)"
    error_message = "Schedule expression is not matching expected value of rate(5 minutes)"
  }
}

run "eventbridge_default_is_enabled" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.fsx_health_lambda_schedule.state == "ENABLED"
    error_message = "CloudWatch EventBride rule state is not matching state of ENABLED"
  }
}

##
# The default value for CloudWatch Alarm property treat_missing_data should be set to breaching.
##
run "aws_cloudwatch_metric_alarm_default_treat_missing_data" {
  command = plan
  variables {
    filesystem_ids           = ["fs-01234567890123456"]
    enable_cloudwatch_alarms = true
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.this["fs-01234567890123456"].treat_missing_data == "breaching"
    error_message = "The default value for treat_missing_data is not set to breaching."
  }
}
