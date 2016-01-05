Rails.application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: Setting.domain }
  config.action_mailer.delivery_method = :letter_opener

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  config.assets.debug = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = false

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = false

  config.active_job.queue_adapter = :inline

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
