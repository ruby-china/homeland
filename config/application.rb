require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Rails.load

module Homeland
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join("plugins", "*/locales", "*.{rb,yml}").to_s]
    config.i18n.default_locale = "en"
    config.i18n.fallbacks = true
    config.i18n.available_locales = ["en", "zh-CN"]

    config.autoload_paths += [
      Rails.root.join("lib")
    ]

    config.generators do |g|
      g.fixture_replacement :factory_bot, dir: "test/factories"
    end

    config.to_prepare do
      Devise::Mailer.layout "mailer"
    end

    config.after_initialize do
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

    config.active_record.async_query_executor = :multi_thread_pool

    config.action_cable.mount_path = ENV["ACTIONCABLE_DISABLE"].present? ? "/_cable" : "/cable"
  end
end

unless ENV["RAILS_PRECOMPILE"].present?
  # Homeland boot must keep in here
  require "homeland"
end
