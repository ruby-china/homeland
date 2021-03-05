# frozen_string_literal: true

require_relative "./test_helper"
require "minitest/spec"

MiniTest::Spec.register_spec_type(/Controller$/, ActionDispatch::IntegrationTest)

require_relative "./support/api_controller_test"
