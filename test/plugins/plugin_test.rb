# frozen_string_literal: true

require "test_helper"

class Homeland::PluginTest < ActiveSupport::TestCase
  setup do
    @plugin = Homeland.register_plugin do |plugin|
      plugin.name = "foo"
      plugin.version = "0.1.0"
      plugin.display_name = "Foo bar"
      plugin.root_path = "/foo"
      plugin.admin_path = "/admin/foo"
      plugin.description = "Hello this is foo bar"
      plugin.navbar_link = true
      plugin.user_menu_link = true
      plugin.admin_navbar_link = true
    end

    @plugin1 = Homeland.register_plugin do |plugin|
      plugin.name = "dar"
      plugin.display_name = "Dar bar"
      plugin.navbar_link = false
      plugin.user_menu_link = false
    end
  end

  test ".register_plugin" do
    assert_kind_of Homeland::Plugin, @plugin
    assert_equal "foo", @plugin.name
    assert_equal "0.1.0", @plugin.version
    assert_equal "Foo bar", @plugin.display_name
    assert_equal "/foo", @plugin.root_path
    assert_equal "/admin/foo", @plugin.admin_path
    assert_equal "Hello this is foo bar", @plugin.description
    assert_equal true, @plugin.navbar_link
    assert_equal true, @plugin.user_menu_link
    assert_equal true, @plugin.admin_navbar_link
    assert_equal false, @plugin.uninstallable?

    assert_equal "0.0.0", @plugin1.version
    assert_equal "dar", @plugin1.name
    assert_equal "Dar bar", @plugin1.display_name
    assert_equal false, @plugin1.navbar_link
    assert_nil @plugin1.admin_navbar_link
    assert_equal false, @plugin1.user_menu_link
  end

  test ".migrate_plugin" do
    assert_equal true, Homeland.respond_to?(:migrate_plugin)
  end

  test ".plugins work" do
    refute_equal nil, Homeland.plugins.find { |p| p.name == "foo" }
    refute_equal nil, Homeland.plugins.find { |p| p.name == "dar" }
  end

  test ".sorted_plugins work" do
    refute_equal nil, Homeland.plugins.sort.find { |p| p.name == "foo" }
    refute_equal nil, Homeland.plugins.sort.find { |p| p.name == "dar" }

    Setting.stub(:sorted_plugins, ["wiki", "site", "note"]) do
      assert_kind_of Array, Homeland.plugins.sort
    end
  end

  test ".navbar_plugins work" do
    refute_equal nil, Homeland.navbar_plugins.find { |p| p.name == "foo" }
    assert_nil Homeland.navbar_plugins.find { |p| p.name == "dar" }
  end

  test ".admin_navbar_plugins work" do
    refute_equal nil, Homeland.admin_navbar_plugins.find { |p| p.name == "foo" }
    assert_nil Homeland.admin_navbar_plugins.find { |p| p.name == "dar" }
  end

  test ".user_menu_plugins work" do
    refute_equal nil, Homeland.user_menu_plugins.find { |p| p.name == "foo" }
    assert_nil Homeland.user_menu_plugins.find { |p| p.name == "dar" }
  end
end
