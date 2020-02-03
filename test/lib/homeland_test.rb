# frozen_string_literal: true

require "test_helper"

class HomelandTest < ActiveSupport::TestCase
  test "boot_at" do
    assert_kind_of Time, Homeland.boot_at
  end

  test "find_plugin" do
    plugin = Homeland.find_plugin("test")
    assert_kind_of Homeland::Plugin, plugin
    assert_equal "test", plugin.name
  end
end
