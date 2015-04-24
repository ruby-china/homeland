# coding: utf-8
require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"
require 'sprockets/railtie'

if defined?(Bundler)
  Bundler.require *Rails.groups(assets: %w(production development test))
end

module RubyChina
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths += %W(#{config.root}/uploaders)

    config.time_zone = 'Beijing'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = "zh-CN"

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    config.mongoid.include_root_in_json = false

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

    config.action_view.sanitized_allowed_attributes = %w{target}

    config.to_prepare {
      Devise::Mailer.layout "mailer"
    }

    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '/api/*', headers: :any, methods: [:get, :post, :put, :delete, :destroy]
      end
    end

    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    config.cache_store = [:dalli_store,"127.0.0.1", { namespace: "rb-cn", compress: true }]

    config.middleware.insert 0, Rack::UTF8Sanitizer
  end
end

require "markdown"

$memory_store = ActiveSupport::Cache::MemoryStore.new

I18n.config.enforce_available_locales = false
I18n.locale = 'zh-CN'

# GC::Profiler.enable