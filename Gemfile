# coding: utf-8
if ENV['USE_OFFICIAL_GEM_SOURCE']
  source 'https://rubygems.org'
else
  source 'https://ruby.taobao.org'
end

gem "rails", "4.1.1"
gem 'turbolinks', '~> 2.2.2'
gem 'jquery-turbolinks', '~> 2.0.2'
gem 'actionpack-action_caching', '1.1.1'
gem 'sass-rails', '~> 4.0.2'
gem 'coffee-rails', "~> 4.0.0"
gem 'uglifier', '>= 1.3.0'

gem "rails-i18n","0.1.8"
gem "jquery-rails", "3.0.4"
gem "rails_autolink", ">= 1.1.0"
gem "md_emoji", "1.0.2"
gem 'exception_notification'
gem "jbuilder", "~> 2.0.2"

# 上传组件
gem 'carrierwave', '0.6.2'
gem 'carrierwave-upyun', '0.1.7'
gem 'mini_magick','3.7.0', require: false

# Mongoid 辅助插件
gem "mongoid", github: 'mongoid/mongoid', ref: 'da35e0cd0fc17651c263e0f74d90b0adf5fbb409'
gem 'mongoid_auto_increment_id', "0.6.4"
gem 'mongoid_rails_migrations', '1.0.0'

# 用户系统
gem 'devise', '3.0.1'
gem 'devise-encryptable', '0.1.2'

# 分页
gem 'will_paginate', '3.0.4'

# Bootstrap
gem 'anjlab-bootstrap-rails', '2.0.3.2', require: 'bootstrap-rails'
gem 'bootstrap-will_paginate', '0.0.3'
gem 'bootstrap_helper', '4.2.3'

# 三方平台 OAuth 验证登陆
gem "omniauth", "~> 1.0.1"
gem "omniauth-github", "~> 1.1.0"

# permission
gem "cancan", "~> 1.6.10"

gem "hiredis", "~> 0.4.5"
# Redis 命名空间
gem 'redis-namespace','~> 1.3.1'

# 将一些数据存放入 Redis
gem "redis-objects", "0.9.1"

# Markdown 格式 & 文本处理
gem "redcarpet", "~> 3.0.0"
gem "rouge", "~> 1.3.4"
gem 'nokogiri', "~> 1.5.6"
gem 'auto-space', '0.0.2'

# YAML 配置信息
gem "settingslogic", "~> 2.0.9"

gem "cells", '~> 3.9.1'

# 队列
gem "sidekiq", "2.17.7"
# Sidekiq Web
gem 'sinatra', '>= 1.3.0', :require => nil

gem 'faye-rails','1.0.0'

# 分享功能
gem "social-share-button", '0.1.5'

# 表单
gem 'simple_form', "3.0.2"

# API
gem 'grape', github: 'intridea/grape', ref: 'd24bd2f758544244ac65f19c69b94f0ffc34e71b'

# Mailer
gem 'postmark', '0.9.15'
gem 'postmark-rails', '0.4.1'

gem "god"

gem 'dalli', '2.7.1'
gem 'eventmachine', '1.0.3'
gem "puma", "2.6.0"
# Faye Server 需要
gem 'thin', "1.5.0"
# for api 跨域
gem 'rack-cors', require: 'rack/cors'

group :development, :test do
  gem 'capistrano', '2.9.0', require: false
  gem 'rvm-capistrano', require: false
  gem 'rspec-rails', '~> 2.14.2'
  gem 'factory_girl_rails', '1.4.0'
  gem 'database_cleaner'
  gem "rspec-cells", '0.1.10'
  gem "capybara", "~> 0.4.1"
  gem 'api_taster', '0.6.0'
  gem "letter_opener"

  # 用于组合小图片
  gem "sprite-factory", "1.4.1", require: false
  gem 'chunky_png', "1.2.8", require: false

  gem 'jasmine-rails', '~> 0.6.0'
  # gem "mongoid_colored_logger", "0.2.3"

  gem "quiet_assets", "~> 1.0.2"
end

group :production do
  gem 'newrelic_rpm'
end
