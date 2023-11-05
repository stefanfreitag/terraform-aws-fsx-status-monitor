module "fsx_monitor" {
  source                   = "../.."
  filesystem_ids           = []
  enable_cloudwatch_alarms = false
  enable_sns_notifications = false
  tags = {
    "Name" = "fsx-monitor"
  }
}
