# coding: utf-8  
require File.expand_path('../boot', __FILE__)
APP_VERSION = '0.5.1'

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Homeland
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.mongoid.observers = :juggernaut_observer

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = "zh-CN"

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password,:password_confirm]
    
    config.mongoid.logger = Logger.new($stdout, :warn)
    
    require "rack/sprockets"
    config.middleware.use "Rack::Sprockets", :load_path => ["app/javascripts/", "app/javascripts/lib/"], :hosted_at => '/assets'
    
    require "rack/less"
    config.middleware.use "Rack::Less"
    
    config.mongoid.include_root_in_json = false
  end
end
I18n.locale = 'zh-CN'

# 配置文件载入
APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

require 'yaml'
YAML::ENGINE.yamler= 'syck'
