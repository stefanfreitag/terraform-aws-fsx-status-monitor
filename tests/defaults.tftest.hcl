run "eventbridge_default_schedule_expression" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.fsx_health_lambda_schedule.schedule_expression == "rate(5 minutes)"
    error_message = "Schedule expression is not matching expected value of rate(5 minutes)"
  }
}
