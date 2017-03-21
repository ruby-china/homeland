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

    # Get plugin list that enabled navbar
    def admin_navbar_plugins
      sorted_plugins.select { |plugin| plugin.admin_navbar_link == true && plugin.admin_path.present? }
    end

    # Get plugin list that enabled navbar
    def user_menu_plugins
      sorted_plugins.select { |plugin| plugin.user_menu_link == true && plugin.root_path.present? }
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
