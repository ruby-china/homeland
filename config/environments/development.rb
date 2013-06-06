# coding: utf-8
RubyChina::Application.configure do
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
  config.action_mailer.delivery_method   = :postmark
  config.action_mailer.postmark_settings = { :api_key => Setting.email_password }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
  config.cache_store = [:dalli_store,"127.0.0.1", {:namespace => "rb-cn", :compression => true}]

  config.assets.debug = true
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
