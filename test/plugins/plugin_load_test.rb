# frozen_string_literal: true

require "test_helper"

class PluginLoadTest < ActiveSupport::TestCase
  test "base load" do
    assert_includes Homeland.plugins.collect(&:name), "test"
    plugin = Homeland.plugins.find { |p| p.name == "test" }
    assert_kind_of Homeland::Plugin, plugin
    assert_equal "Test plugin", plugin.display_name
    assert_equal "Plugin for Homeland development test.", plugin.description
    assert_equal "0.0.0", plugin.version
    assert_equal Rails.root.join("plugins", "test").to_s, plugin.source_path
    assert_equal true, plugin.uninstallable?
  end

  test "I18n load paths" do
    assert_includes Rails.application.config.i18n.load_path, Rails.root.join("plugins/test/locales/test.yml").to_s
    assert_equal "This is Plugin i18n test key", I18n.t("test.this_is_plugin_test_key")
  end
end
