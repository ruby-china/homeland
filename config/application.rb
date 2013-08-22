# coding: utf-8
require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"
require 'sprockets/railtie'


if defined?(Bundler)
  Bundler.require *Rails.groups(:assets => %w(production development test))
end

module RubyChina
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/uploaders)
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/app/grape)

    config.time_zone = 'Beijing'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = "zh-CN"

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirm, :token, :private_token]

    config.mongoid.include_root_in_json = false

    config.assets.enabled = true
    config.assets.version = '1.0'

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end

    config.to_prepare {
      Devise::Mailer.layout "mailer"
    }
    
    config.assets.precompile += %w(application.css app.js topics.css topics.js window.css front.css cpanel.css
        users.css pages.css pages.js notes.css notes.js 
        mobile.css home.css)
  end
end

require "markdown"

I18n.locale = 'zh-CN'



