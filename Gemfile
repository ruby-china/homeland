if ENV['USE_OFFICIAL_GEM_SOURCE']
  source 'https://rubygems.org'
else
  source 'https://ruby.taobao.org'
end

ruby '2.3.0'

gem 'rails', '~> 4.2.5'
gem 'sprockets'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'jbuilder'
gem 'turbolinks', git: 'https://github.com/rails/turbolinks.git'
gem 'jquery-turbolinks'
gem 'dropzonejs-rails'

gem 'actionpack-action_caching'
gem 'rails-i18n'
gem 'http_accept_language'
gem 'rails_autolink'
gem 'md_emoji'
gem 'exception_notification'

gem 'doorkeeper'
gem 'doorkeeper-i18n'

gem 'rails-perftest'
gem 'ruby-prof'

# 上传组件
gem 'carrierwave', '~> 0.10.0'
gem 'carrierwave-upyun'
gem 'mini_magick'

gem 'rucaptcha'
gem 'letter_avatar'

# Mongoid 辅助插件
gem 'mongoid', '5.0.0'
gem 'mongoid_auto_increment_id'
gem 'mongoid_rails_migrations'

# 用户系统
gem 'devise', '~> 3.5.1'
gem 'devise-async'
gem 'devise-encryptable'

# 分页
gem 'will_paginate'

# 三方平台 OAuth 验证登陆
gem 'omniauth', '~> 1.2.2'
gem 'omniauth-github', '~> 1.1.0'

# permission
gem 'cancancan', '~> 1.8.4'

gem 'redis', '~> 3.2.1'
gem 'hiredis', '~> 0.6.0'
# Redis 命名空间
gem 'redis-namespace', '~> 1.5.1'
# 将一些数据存放入 Redis
gem 'redis-objects', '1.1.0'

# Markdown 格式 & 文本处理
gem 'redcarpet', '~> 3.3.4'
gem 'rouge', '~> 1.8.0'
gem 'auto-space', '0.0.4'
gem 'nokogiri'

# YAML 配置信息
gem 'settingslogic', '~> 2.0.9'

# 队列
gem 'sidekiq'
# Sidekiq Web
gem 'sinatra', require: nil

gem 'message_bus'

# 分享功能
gem 'social-share-button', '0.1.5'

# 表单
gem 'simple_form', '3.1.0'

# API
gem 'grape', '0.7.0'
gem 'active_model_serializers'
gem 'grape-active_model_serializers'

# Mailer
gem 'postmark', '0.9.15'
gem 'postmark-rails', '0.4.1'

# Dalli, kgio is for Dalli
gem 'kgio'
gem 'dalli', '2.7.4'

gem 'unicorn', '5.0.0'

gem 'parallel'

# for api 跨域
gem 'rack-cors', require: 'rack/cors'
gem 'rack-utf8_sanitizer'

# Mini profiler
gem 'rack-mini-profiler', require: false

# gem 'newrelic_rpm'
# gem 'newrelic_moped'
# gem 'newrelic-grape'

gem 'oneapm_rpm'

group :development do
  gem 'derailed'
end

group :development, :test do
  gem 'capistrano', '2.9.0', require: false
  gem 'capistrano-unicorn'
  gem 'rvm-capistrano', require: false
  gem 'capistrano-sidekiq'

  gem 'rubocop'
  gem 'rspec-rails', '~> 3.4'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'database_cleaner'
  gem 'capybara', '~> 2.3.0'
  gem 'api_taster', '0.6.0'

  gem 'jasmine-rails', '~> 0.10.2'

  gem 'colorize'
  gem 'letter_opener'

  gem 'puma', '~> 2.14.0'

  # Better Errors
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'tunemygc'

  gem 'bundler-audit', require: false
end
