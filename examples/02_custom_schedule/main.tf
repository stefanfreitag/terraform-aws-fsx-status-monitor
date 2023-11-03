module "fsx_monitor" {
  source                   = "../.."
  email                    = []
  enable_cloudwatch_alarms = true
  enable_sns_notifications = true
  filesystem_ids           = []
  schedule_expression      = "rate(1 minute)"
  tags = {
    "Name" = "fsx-monitor"
  }
}
