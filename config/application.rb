require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RubyChina
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Beijing'

    # Ensure App config files exist.
    if Rails.env.development?
      %w(config redis secrets).each do |fname|
        filename = "config/#{fname}.yml"
        next if File.exist?(Rails.root.join(filename))
        FileUtils.cp(Rails.root.join("#{filename}.default"), Rails.root.join(filename))
      end
    end

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = 'zh-CN'
    config.i18n.available_locales = ['zh-CN', 'en', 'zh-TW']

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.i18n.fallbacks = true

    config.autoload_paths.push(*%W(#{config.root}/lib))
    config.eager_load_paths.push(*%W(#{config.root}/lib/exception_notifier))

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    config.to_prepare do
      Devise::Mailer.layout 'mailer'
      # Only Applications list
      Doorkeeper::ApplicationsController.layout 'simple'
      # Only Authorization endpoint
      Doorkeeper::AuthorizationsController.layout 'simple'
      # Only Authorized Applications
      Doorkeeper::AuthorizedApplicationsController.layout 'simple'
    end

    config.cache_store = [:dalli_store, '127.0.0.1', { namespace: 'rb-1', compress: true }]

    config.active_job.queue_adapter = :sidekiq

    config.active_record.raise_in_transactional_callbacks = true
  end
end

require 'markdown'

$memory_store = ActiveSupport::Cache::MemoryStore.new

I18n.config.enforce_available_locales = false
I18n.locale = 'zh-CN'
# GC::Profiler.enable
