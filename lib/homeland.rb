require 'homeland/version'

module Homeland
  class << self
    def file_store
      @file_store ||= ActiveSupport::Cache::FileStore.new(Rails.root.join('tmp/cache'))
    end

    # Get plugin list
    def plugins
      @plugins || []
    end

    # Plugin list sorted by `config.modules` order
    def sorted_plugins
      @sorted_plugins ||= plugins.sort do |a, b|
        Setting.module_list.index(a.name)  <=> Setting.module_list.index(b.name)
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
      plugin
    end
  end
end
