require_relative "./test_helper"
require "minitest/spec"
require_relative "./support/api_controller_test"

MiniTest::Spec.register_spec_type /Controller$/, ActionDispatch::IntegrationTest