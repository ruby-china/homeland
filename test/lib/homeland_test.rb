# frozen_string_literal: true

require "test_helper"

class HomelandTest < ActiveSupport::TestCase
  test "boot_at" do
    assert_kind_of Time, Homeland.boot_at
  end
end