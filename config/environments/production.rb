# coding: utf-8
RubyChina::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # Use a different logger for distributed setups
  # config.logger = Logger.new("#{Rails.root}/log/#{Rails.env}.log", 'weekly')
  # config.logger.level = Logger::INFO

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  config.cache_store = [:dalli_store,"127.0.0.1", {:namespace => "rb-cn", :compression => true}]

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  config.action_controller.asset_host = Setting.upload_url

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :sendmail

  # Enable threaded mode
  # config.threadsafe!


  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  config.assets.js_compressor  = :uglifier
  config.assets.css_compressor = :scss
  config.assets.precompile += %w(application.css app.js topics.css topics.js window.css front.css cpanel.css search.css
  users.css pages.css pages.js notifications.js notifications.css sites.css sites.js
  gfdynamicfeedcontrol.css gfdynamicfeedcontrol.js mobile.css home.css)


end

