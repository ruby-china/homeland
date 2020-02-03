# frozen_string_literal: true

require "homeland/version"
require "homeland/plugin"

module Homeland
  cattr_reader :boot_at

  class << self
    def file_store
      @file_store ||= ActiveSupport::Cache::FileStore.new(Rails.root.join("tmp/cache"))
    end

    # Get plugin list
    def plugins
      @plugins || []
    end

    # Plugin list sorted by `config.modules` order
    def sorted_plugins
      @sorted_plugins ||= plugins.sort do |a, b|
        Setting.modules.index(a.name) <=> Setting.modules.index(b.name)
      end
    end

    # Get plugin list that enabled navbar
    def navbar_plugins
      sorted_plugins.select { |plugin| plugin.navbar_link == true && plugin.root_path.present? }
    end

    # Get plugin list that enabled admin navbar
    def admin_navbar_plugins
      sorted_plugins.select { |plugin| plugin.admin_navbar_link == true && plugin.admin_path.present? }
    end

    # Get plugin list that enabled user menu
    def user_menu_plugins
      sorted_plugins.select { |plugin| plugin.user_menu_link == true && plugin.root_path.present? }
    end

    # Register a new plugin
    #
    # *Example*
    #
    # see Homeland::Plugin
    #
    #   Homeland.register_plugin do |plugin|
    #     plugin.name = 'test'
    #     plugin.display_name = 'Test Plugin'
    #     plugin.version = '0.1.0'
    #     plugin.description = 'This is a test Homeland Plugin.'
    #     plugin.navbar_link = true
    #     plugin.root_path = "/test"
    #   end
    #
    # More example see: https://github.com/ruby-china/homeland-press
    #
    def register_plugin
      @plugins ||= []
      plugin = Homeland::Plugin.new
      yield plugin
      @plugins << plugin
      @sorted_plugins = nil
      plugin.version ||= "0.0.0"
      plugin
    end

    def find_plugin(name)
      self.plugins.find { |p| p.name == name.strip }
    end

    def boot
      ActiveSupport.on_load(:after_initialize) do
        puts "=> Booting Homeland" unless Rails.env.test?
        Homeland::Plugin.boot
        puts "=> Plugins: #{Homeland.plugins.collect(&:name).join(", ")}" unless Rails.env.test?
        @@boot_at = Time.now
      end
    end

    def reboot
      `touch #{Rails.root.join("tmp/restart.txt")}`
    end
  end
end

Homeland.boot
