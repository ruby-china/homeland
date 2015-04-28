# coding: utf-8
if ENV['USE_OFFICIAL_GEM_SOURCE']
  source 'https://rubygems.org'
else
  source 'https://ruby.taobao.org'
end

gem 'rails', '4.2.1'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'jbuilder'

gem 'actionpack-action_caching', '1.1.1'
gem 'rails-i18n'
gem 'rails_autolink', '>= 1.1.0'
gem 'md_emoji', '1.0.2'
gem 'exception_notification'

gem 'rails-perftest'
gem 'ruby-prof'

# 上传组件
gem 'carrierwave', '~> 0.10.0'
gem 'carrierwave-upyun', '0.1.8'
gem 'mini_magick','3.7.0', require: false

# Mongoid 辅助插件
gem 'mongoid', '4.0.2'
gem 'mongoid-rails'
gem 'mongoid_auto_increment_id', '0.6.4'
gem 'mongoid_rails_migrations', '1.0.0'

# 用户系统
gem 'devise', '~> 3.4.0'
gem 'devise-encryptable', '0.1.2'

# 分页
gem 'will_paginate', '3.0.7'

# 三方平台 OAuth 验证登陆
gem 'omniauth', '~> 1.2.2'
gem 'omniauth-github', '~> 1.1.0'

# permission
gem 'cancancan', '~> 1.8.4'

gem 'redis', '~> 3.2.1'
gem "hiredis", "~> 0.6.0"
# Redis 命名空间
gem 'redis-namespace','~> 1.5.1'
# 将一些数据存放入 Redis
gem 'redis-objects', '1.1.0'

# Markdown 格式 & 文本处理
gem 'redcarpet', '~> 3.2.3'
gem 'rouge', '~> 1.8.0'
gem 'auto-space', '0.0.4'

# YAML 配置信息
gem 'settingslogic', '~> 2.0.9'

# 队列
gem 'sidekiq', '3.3.4'
# Sidekiq Web
gem 'sinatra', '>= 1.3.0', :require => nil

gem 'message_bus'

# 分享功能
gem 'social-share-button', '0.1.5'

# 表单
gem 'simple_form', '3.1.0'

# API
gem 'grape', '0.7.0'
gem 'grape-entity', '0.4.4'

# Mailer
gem 'postmark', '0.9.15'
gem 'postmark-rails', '0.4.1'

gem 'god'

# Dalli, kgio is for Dalli
gem 'kgio'
gem 'dalli', '2.7.1'

gem 'puma'

# for api 跨域
gem 'rack-cors', require: 'rack/cors'
gem 'rack-utf8_sanitizer'

# Mini profiler
gem 'rack-mini-profiler', require: false

group :development, :test do
  gem 'capistrano', '2.9.0', require: false
  gem 'rvm-capistrano', require: false
  gem 'capistrano-sidekiq'
  gem 'rspec-rails', '~> 3.1'
  gem 'factory_girl_rails', '1.4.0'
  gem 'database_cleaner'
  gem 'capybara', '~> 2.3.0'
  gem 'api_taster', '0.6.0'
  gem 'letter_opener'

  gem 'mongoid_colored_logger'
  gem 'colorize'

  gem 'jasmine-rails', '~> 0.10.2'
  gem 'derailed_benchmarks', github: "schneems/derailed_benchmarks"
end

group :production do
  gem 'newrelic_rpm'
  gem 'newrelic_moped'
end
