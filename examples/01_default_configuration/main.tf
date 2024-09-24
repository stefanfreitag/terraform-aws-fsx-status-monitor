module "fsx_monitor" {
  source                   = "../.."
  filesystem_ids           = []
  enable_cloudwatch_alarms = false
  tags = {
    "Name" = "fsx-monitor"
  }
}
