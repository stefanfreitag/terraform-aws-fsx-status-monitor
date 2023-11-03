module "fsx_monitor" {
  source         = "../.."
  filesystem_ids = []
  tags = {
    "Name" = "fsx-monitor"
  }
}
