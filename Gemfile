if ENV['USE_OFFICIAL_GEM_SOURCE']
  source 'https://rubygems.org'
else
  source 'https://gems.ruby-china.org'
end

gem 'rails', '~> 5.0.0'
gem 'sprockets'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'jbuilder'
gem 'turbolinks', '~> 5.0.0'
gem 'dropzonejs-rails'

gem 'pg'

gem 'rack-attack'

gem 'rails-i18n', '5.0.0.beta4'
gem 'http_accept_language'
gem 'rails_autolink'
gem 'twemoji'
gem 'jquery-atwho-rails'
gem 'font-awesome-rails'

# OAuth Provider
gem 'doorkeeper'
gem 'doorkeeper-i18n'

gem 'bulk_insert'

# 上传组件
gem 'carrierwave'
gem 'carrierwave-upyun'
gem 'mini_magick'

# 验证码，头像
gem 'rucaptcha'
gem 'letter_avatar'

# 用户系统
gem 'devise'
gem 'devise-encryptable'

# 通知系统
gem 'notifications'
gem 'ruby-push-notifications'

# 分页
gem 'will_paginate'

# 搜索
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'redis-search'

# 三方平台 OAuth 验证登陆
gem 'omniauth'
gem 'omniauth-github'

# Permission
gem 'cancancan'

# Redis
gem 'redis'
gem 'hiredis'
gem 'redis-namespace'
gem 'redis-objects'

# Cache
gem 'second_level_cache'

# Setting
gem 'rails-settings-cached'

# Markdown
gem 'redcarpet', '~> 3.3.4'
gem 'rouge'
gem 'auto-space'

# 队列
gem 'sidekiq'
# Sidekiq Web
gem 'sinatra', '~> 2.0.0.beta2'

# 分享功能
gem 'social-share-button'

# 表单
gem 'simple_form'

# API
gem 'active_model_serializers'

# Mailer Service
gem 'postmark'
gem 'postmark-rails'

# Dalli, kgio is for Dalli
gem 'kgio'
gem 'dalli'

gem 'puma'

# API cors
gem 'rack-cors', require: 'rack/cors'
gem 'rack-utf8_sanitizer'

gem 'oneapm_rpm'
gem 'exception_notification'
gem 'status-page'

group :development do
  gem 'capistrano', '2.9.0', require: false
  gem 'rvm-capistrano', require: false
  gem 'capistrano-sidekiq'
  gem 'derailed'
  # Better Errors
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :development, :test do
  gem 'listen'
  gem 'rubocop', '~> 0.39.0', require: false
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'jasmine-rails', '~> 0.10.2'
  gem 'letter_opener'

  gem 'codecov', require: false
  gem 'bundler-audit', require: false
  gem 'pry-byebug'
end
