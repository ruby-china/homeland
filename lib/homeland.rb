# frozen_string_literal: true

require "homeland/version"
require "homeland/plugin"

unless ENV["RAILS_PRECOMPILE"]
  # Preload Jieba
  require "homeland/search"
end

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

    # Get plugin list that enabled navbar
    def navbar_plugins
      plugins.sort.select { |plugin| plugin.navbar_link == true && plugin.root_path.present? }
    end

    # Get plugin list that enabled admin navbar
    def admin_navbar_plugins
      plugins.sort.select { |plugin| plugin.admin_navbar_link == true && plugin.admin_path.present? }
    end

    # Get plugin list that enabled user menu
    def user_menu_plugins
      plugins.sort.select { |plugin| plugin.user_menu_link == true && plugin.root_path.present? }
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
      plugin.source_path = File.dirname(caller(1..1).first)
      plugin
    end

    def find_plugin(name)
      plugins.find { |p| p.name == name.strip }
    end

    def boot
      # puts "=> Booting Homeland" unless Rails.env.test?
      Homeland::Plugin.boot
      # puts "=> Plugins: #{Homeland.plugins.collect(&:name).join(", ")}" unless Rails.env.test?
      @@boot_at = Time.now
      # end
    end

    def reboot
      Setting.require_restart = "0"
      FileUtils.touch(Rails.root.join("tmp/restart.txt"))
    end

    # Run rails migrate directly for Plugin migrations
    # Used in plugin
    def migrate_plugin(migration_path)
      # Execute Migrations on engine load.
      ActiveRecord::Migrator.migrations_paths += [migration_path]
      begin
        ActiveRecord::Tasks::DatabaseTasks.migrate
      rescue ActiveRecord::NoDatabaseError
      end
    end
  end
end

Homeland.boot
