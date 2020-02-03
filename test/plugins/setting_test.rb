# frozen_string_literal: true

require "test_helper"

class SettingPluginTest < ActiveSupport::TestCase
  test "editable_keys" do
    assert_kind_of Array, Setting.editable_keys
  end
end
