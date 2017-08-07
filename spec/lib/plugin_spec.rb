require 'rails_helper'

describe Homeland::Plugin do
  describe '.register_plugin' do
    before do
      @plugin = Homeland.register_plugin do |plugin|
        plugin.name         = "foo"
        plugin.version      = '0.1.0'
        plugin.display_name = "Foo bar"
        plugin.root_path    = "/foo"
        plugin.admin_path   = "/admin/foo"
        plugin.description  = "Hello this is foo bar"
        plugin.navbar_link       = true
        plugin.user_menu_link    = true
        plugin.admin_navbar_link = true
      end

      @plugin1 = Homeland.register_plugin do |plugin|
        plugin.name         = "dar"
        plugin.display_name = "Dar bar"
        plugin.navbar_link = false
        plugin.user_menu_link = false
      end
    end

    it 'should work' do
      expect(@plugin).to be_a(Homeland::Plugin)
      expect(@plugin.name).to eq "foo"
      expect(@plugin.version).to eq '0.1.0'
      expect(@plugin.display_name).to eq "Foo bar"
      expect(@plugin.root_path).to eq "/foo"
      expect(@plugin.admin_path).to eq "/admin/foo"
      expect(@plugin.description).to eq 'Hello this is foo bar'
      expect(@plugin.navbar_link).to eq true
      expect(@plugin.user_menu_link).to eq true
      expect(@plugin.admin_navbar_link).to eq true

      expect(@plugin1.version).to eq nil
      expect(@plugin1.name).to eq 'dar'
      expect(@plugin1.display_name).to eq 'Dar bar'
      expect(@plugin1.navbar_link).to eq false
      expect(@plugin1.admin_navbar_link).to eq nil
      expect(@plugin1.user_menu_link).to eq false
    end

    it '.plugins work' do
      expect(Homeland.plugins.find { |p| p.name == 'foo' }).not_to eq nil
      expect(Homeland.plugins.find { |p| p.name == 'dar' }).not_to eq nil
    end

    it '.sorted_plugins work' do
      expect(Homeland.sorted_plugins.find { |p| p.name == 'foo' }).not_to eq nil
      expect(Homeland.sorted_plugins.find { |p| p.name == 'dar' }).not_to eq nil
    end

    it '.navbar_plugins work' do
      expect(Homeland.navbar_plugins.find { |p| p.name == 'foo' }).not_to eq nil
      expect(Homeland.navbar_plugins.find { |p| p.name == 'dar' }).to eq nil
    end

    it '.admin_navbar_plugins work' do
      expect(Homeland.admin_navbar_plugins.find { |p| p.name == 'foo' }).not_to eq nil
      expect(Homeland.admin_navbar_plugins.find { |p| p.name == 'dar' }).to eq nil
    end

    it '.user_menu_plugins work' do
      expect(Homeland.user_menu_plugins.find { |p| p.name == 'foo' }).not_to eq nil
      expect(Homeland.user_menu_plugins.find { |p| p.name == 'dar' }).to eq nil
    end
  end
end
