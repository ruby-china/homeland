# frozen_string_literal: true

require_relative "test_helper"
require "minitest/spec"
require "minitest/autorun"

Minitest::Spec.register_spec_type(/Controller$/, ActionDispatch::IntegrationTest)

require_relative "support/api_controller_test"
