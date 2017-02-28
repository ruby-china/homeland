module Homeland
  class << self
    def version
      '2.7.0'
    end

    def file_store
      @file_store ||= ActiveSupport::Cache::FileStore.new(Rails.root.join('tmp/cache'))
    end

    # Get plugin list
    def plugins
      @plugins || []
    end

    # Get plugin list that enabled navbar
    def navbar_plugins
      plugins.select { |plugin| plugin.navbar_link == true }
    end

    # Get plugin list that enabled navbar
    def user_menu_plugins
      plugins.select { |plugin| plugin.user_menu_link == true }
    end

    # Register a new plugin
    #
    # ## Example
    #
    # Homeland.register_plugin do
    #   self.name = "press"
    #   self.display_name = "头条"
    #   self.navbar_link = true
    # end
    def register_plugin
      @plugins ||= []
      plugin = Homeland::Plugin.new
      yield plugin
      @plugins << plugin
      plugin
    end
  end
end
