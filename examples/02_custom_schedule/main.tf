module "fsx_monitor" {
  source              = "../.."
  schedule_expression = "rate(15 minutes)"
  tags = {
    "Name" = "fsx-monitor"
  }
}
