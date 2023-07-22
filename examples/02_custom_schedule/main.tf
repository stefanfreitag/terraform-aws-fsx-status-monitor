module "fsx_monitor" {
  source              = "../.."
  schedule_expression = "rate(15 minutes)"
}
