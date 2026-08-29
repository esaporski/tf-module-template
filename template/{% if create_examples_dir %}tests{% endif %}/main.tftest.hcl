run "setup_tests" {
  command = apply

  module {
    source = "./tests/setup"
  }
}
