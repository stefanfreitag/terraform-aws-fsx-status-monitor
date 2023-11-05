run "ignore_states_with_valid_fsx_state" {
  command = plan
  variables {
    ignore_states = ["AVAILABLE"]
  }
}

run "ignore_states_with_invalid_state" {
  command = plan
  variables {
    ignore_states = ["AVAILABLE", "UNKNOWN_STATE"]
  }
  expect_failures = [
    var.ignore_states
  ]
}
