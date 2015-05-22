# coding: utf-8
require 'sidekiq/testing/inline'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { :host => Setting.domain }
  config.action_mailer.delivery_method   = :letter_opener

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  config.assets.debug = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = false

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end

@last_api_change = Time.now
api_reloader = ActiveSupport::FileUpdateChecker.new(Dir["#{Rails.root}/app/grape/**/*.rb"]) do |reloader|
  times = Dir["#{Rails.root}/app/grape/**/*.rb"].map{|f| File.mtime(f) }
  files = Dir["#{Rails.root}/app/grape/**/*.rb"].map{|f| f }

  Rails.logger.debug "! Change detected: reloading following files:"
  files.each_with_index do |s,i|
    if times[i] > @last_api_change
      Rails.logger.debug " - #{s}"
      load s
    end
  end

  Rails.application.reload_routes!
  Rails.application.routes_reloader.reload!
  Rails.application.eager_load!
end

ActionDispatch::Reloader.to_prepare do
  api_reloader.execute_if_updated
end
