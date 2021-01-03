# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

module Homeland
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join("plugins", "*/locales", "*.{rb,yml}").to_s]
    config.i18n.default_locale = "en"
    config.i18n.available_locales = ["en", "zh-CN"]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.i18n.fallbacks = true

    config.autoload_paths += [
      Rails.root.join("lib")
    ]

    config.generators do |g|
      g.fixture_replacement :factory_bot, dir: "test/factories"
    end

    config.to_prepare do
      Devise::Mailer.layout "mailer"
      Doorkeeper::ApplicationController.include Homeland::UserNotificationHelper
      # Only Applications list
      Doorkeeper::ApplicationsController.layout "simple"
      # Only Authorization endpoint
      Doorkeeper::AuthorizationsController.layout "simple"
      # Only Authorized Applications
      Doorkeeper::AuthorizedApplicationsController.layout "simple"
    end

    redis_config = Application.config_for(:redis)
    config.cache_store = [:redis_cache_store, { namespace: "cache", url: redis_config["url"], expires_in: 4.weeks }]

    config.active_job.queue_adapter = :sidekiq
    config.middleware.use Rack::Attack

    config.action_cable.mount_path = "/cable"
    config.action_cable.logger = Logger.new("/dev/null")
  end
end

# Homeland boot must keep in here
require "homeland"
