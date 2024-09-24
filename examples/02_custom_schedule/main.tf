module "fsx_monitor" {
  source                   = "../.."
  enable_cloudwatch_alarms = true
  filesystem_ids           = []
  schedule_expression      = "rate(1 minute)"
  tags = {
    "Name" = "fsx-monitor"
  }
}
