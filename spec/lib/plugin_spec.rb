require 'rails_helper'

describe Homeland::Plugin do
  describe '.register_plugin' do
    before do
      @plugin = Homeland.register_plugin do
        self.name = "foo"
        self.display_name = "Foo bar"
        self.root_path = "/foo"
        self.description = "Hello this is foo bar"
        self.navbar_link = true
        self.user_menu_link = true
      end

      @plugin1 = Homeland.register_plugin do
        self.name = "dar"
        self.display_name = "Dar bar"
        self.navbar_link = false
        self.user_menu_link = false
      end
    end

    it 'should work' do
      expect(@plugin).to be_a(Homeland::Plugin)
      expect(@plugin.name).to eq "foo"
      expect(@plugin.display_name).to eq "Foo bar"
      expect(@plugin.root_path).to eq "/foo"
      expect(@plugin.description).to eq 'Hello this is foo bar'
      expect(@plugin.navbar_link).to eq true
      expect(@plugin.user_menu_link).to eq true
    end

    it '.plugins work' do
      expect(Homeland.plugins.find { |p| p.name == 'foo' }).not_to eq nil
      expect(Homeland.plugins.find { |p| p.name == 'dar' }).not_to eq nil
    end

    it '.navbar_plugins work' do
      expect(Homeland.navbar_plugins.find { |p| p.name == 'foo' }).not_to eq nil
      expect(Homeland.navbar_plugins.find { |p| p.name == 'dar' }).to eq nil
    end

    it '.user_menu_plugins work' do
      expect(Homeland.user_menu_plugins.find { |p| p.name == 'foo' }).not_to eq nil
      expect(Homeland.user_menu_plugins.find { |p| p.name == 'dar' }).to eq nil
    end
  end
end
