if ENV['USE_OFFICIAL_GEM_SOURCE']
  source 'https://rubygems.org'
else
  source 'https://ruby.taobao.org'
end

ruby '2.3.0'

gem 'rails', '5.0.0.beta2'
gem 'sprockets'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'jbuilder'
gem 'turbolinks', github: 'rails/turbolinks'
gem 'jquery-turbolinks'
gem 'dropzonejs-rails'

gem 'rack-attack'

gem 'rails-i18n'
gem 'http_accept_language'
gem 'rails_autolink'
gem 'md_emoji'
gem 'exception_notification'

gem 'doorkeeper', github: 'doorkeeper-gem/doorkeeper'
gem 'doorkeeper-i18n'

# gem 'rails-perftest'
# gem 'ruby-prof'

# 上传组件
gem 'carrierwave'
gem 'carrierwave-upyun'
gem 'mini_magick'

gem 'rucaptcha'
gem 'letter_avatar'

gem 'pg'

# 用户系统
gem 'devise', '~> 4.0.0.rc1'
gem 'devise-encryptable'

# 分页
gem 'will_paginate'

# 搜索
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

# 三方平台 OAuth 验证登陆
gem 'omniauth'
gem 'omniauth-github'

# permission
gem 'cancancan', '~> 1.13.1'

gem 'redis'
gem 'hiredis'
# Redis 命名空间
gem 'redis-namespace'
# 将一些数据存放入 Redis
gem 'redis-objects'
gem 'second_level_cache', '2.2.1'

gem 'rails-settings-cached'

# Markdown 格式 & 文本处理
gem 'redcarpet', '~> 3.3.4'
gem 'rouge', '~> 1.8.0'
gem 'auto-space'
gem 'nokogiri'

# YAML 配置信息
gem 'settingslogic'

# 队列
gem 'sidekiq'
# Sidekiq Web
gem 'sinatra', github: 'sinatra/sinatra', require: nil

# 分享功能
gem 'social-share-button'

# 表单
gem 'simple_form'

# API
gem 'grape'
gem 'active_model_serializers', '0.9.2'
gem 'grape-active_model_serializers'

# Mailer
gem 'postmark'
gem 'postmark-rails'

gem 'ruby-push-notifications'

# Dalli, kgio is for Dalli
gem 'kgio'
gem 'dalli'

gem 'puma'

gem 'parallel'

# for api 跨域
gem 'rack-cors', require: 'rack/cors'
gem 'rack-utf8_sanitizer'

# Mini profiler
gem 'rack-mini-profiler', github: 'MiniProfiler/rack-mini-profiler', require: false

gem 'oneapm_rpm'

group :development do
  gem 'capistrano', '2.9.0', require: false
  gem 'rvm-capistrano', require: false
  gem 'capistrano-sidekiq'

  gem 'derailed'

  # Better Errors
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'rubocop'

  gem 'rspec-rails', '3.5.0.beta1'

  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'database_cleaner'
  gem 'capybara'

  gem 'jasmine-rails', '~> 0.10.2'

  gem 'colorize'
  gem 'letter_opener'

  gem 'bundler-audit', require: false
end
