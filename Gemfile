# coding: utf-8
source 'http://ruby.taobao.org'

gem "rails", "4.0.2"
gem 'turbolinks', '~> 1.2.0'
gem 'jquery-turbolinks', '2.0.0'
gem 'actionpack-action_caching', '1.0.0'
gem 'sass-rails', "~> 4.0.0"
gem 'coffee-rails', "~> 4.0.0"
gem 'uglifier', '>= 1.3.0'

gem "rails-i18n","0.1.8"
gem "jquery-rails", "3.0.4"
gem "rails_autolink", ">= 1.1.0"
gem "md_emoji"
gem 'exception_notification'

# 上传组件
gem 'carrierwave', '0.6.2'
gem 'carrierwave-upyun', '0.1.5'
gem 'mini_magick','3.3', require: false

# Mongoid 辅助插件
gem "mongoid", github: 'mongoid/mongoid', ref: '11e45e5a30a45458b83db99ab6c9d9ccc337e66f'
gem 'mongoid_auto_increment_id', "0.6.2"
gem 'mongoid_rails_migrations', '1.0.0'

# 用户系统
gem 'devise', '3.0.1'
gem 'devise-encryptable', '0.1.2'

# 分页
gem 'will_paginate', '3.0.4'

# Bootstrap
gem 'anjlab-bootstrap-rails', '2.0.3.2', require: 'bootstrap-rails'
gem 'bootstrap-will_paginate', '0.0.3'
gem 'bootstrap_helper', github: 'huacnlee/bootstrap-helper'

# 三方平台 OAuth 验证登陆
gem "omniauth", "~> 1.0.1"
gem "omniauth-github", "~> 1.1.0"

# permission
gem "cancan", "~> 1.6.10"

# Redis 命名空间
gem 'redis-namespace','~> 1.2.1'

# 将一些数据存放入 Redis
gem "redis-objects", "0.5.2"

# Markdown 格式 & 文本处理
gem "redcarpet", "~> 3.0.0"
gem "rouge", "~> 1.0.0"
gem 'nokogiri', "~> 1.5.6"
gem 'auto-space', '0.0.2'

# YAML 配置信息
gem "settingslogic", "~> 2.0.9"

gem "cells", '~> 3.8.8'

# 队列
gem "sidekiq", "2.5.3"

gem 'faye-rails','1.0.0'

# 分享功能
gem "social-share-button", '0.1.4'

# 表单
gem 'simple_form', "3.0.0.rc"

# API
gem 'grape', github: 'intridea/grape', branch: 'frontier'

# Mailer
gem 'postmark-rails', '0.4.1'

# Google Analytics performance
gem 'garelic', '0.0.2'

gem "god"

gem 'dalli', '1.1.1'
gem 'eventmachine', '1.0.3'
gem "puma", "2.6.0"
# Faye Server 需要
gem 'thin', "1.5.0"

group :development, :test do
  gem 'capistrano', '2.9.0', require: false
  gem 'rvm-capistrano', require: false
  gem 'rspec-rails', '~> 2.13.2'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem "rspec-cells", '0.1.7'
	gem 'fuubar'
  gem "capybara", "~> 0.4.1"
  gem 'api_taster', '0.6.0'
  gem "letter_opener"

  # 用于组合小图片
  gem "sprite-factory", "1.4.1", require: false
  gem 'chunky_png', "1.2.8", require: false

  gem 'jasmine-rails', github: 'searls/jasmine-rails'
  gem "mongoid_colored_logger", "0.2.2"

  gem "quiet_assets", "~> 1.0.2"
end

group :production do
  gem 'newrelic_rpm', "~> 3.6.8.168"
end
