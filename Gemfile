source 'https://rubygems.org'

gem "rails", "3.2.9"
gem "rails-i18n","0.1.8"
gem "jquery-rails", "2.0.1"
gem "rails_autolink", ">= 1.0.4"
gem "jquery-atwho-rails", "0.1.6"
gem "md_emoji"
gem 'exception_notification'

group :assets do
  gem 'sass-rails', "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', '>= 1.0.3'
end

# 上传组件
gem 'carrierwave', '0.6.2'
gem 'carrierwave-upyun', '0.1.5'
gem 'mini_magick','3.3', :require => false

# Mongoid 辅助插件
gem "mongoid", "3.0.1"
# gem 'mongo-rails-instrumentation','0.2.4'
gem 'mongoid_auto_increment_id', "0.5.0"
gem 'mongoid_rails_migrations', '~> 0.0.14'
gem "mongoid_colored_logger", :github => "huacnlee/mongoid_colored_logger"

# 用户系统
gem 'devise', '2.1.0'
gem 'devise-encryptable'

# 分页
gem 'will_paginate', '3.0.2'

# Bootstrap
gem 'anjlab-bootstrap-rails', '2.0.3.2', :require => 'bootstrap-rails'
gem 'bootstrap-will_paginate', '0.0.3'
gem 'bootstrap_helper', "1.4.1"

# 三方平台 OAuth 验证登陆
gem "omniauth", "~> 1.0.1"
gem "omniauth-github", "~> 1.0.0"

# permission
gem "cancan", "~> 1.6.7"

# Redis 命名空间
gem 'redis-namespace','~> 1.2.1'

# 将一些数据存放入 Redis
gem "redis-objects", "0.5.2"

# Markdown 格式
gem "redcarpet", "~> 2.0.0"
gem "pygments.rb", '~> 0.2.4'

# YAML 配置信息
gem "settingslogic", "~> 2.0.6"

gem "cells", "3.7.1"

# 队列
gem "sidekiq", "2.5.3"

gem 'faye-rails','1.0.0'

gem 'newrelic_rpm'

# 分享功能
gem "social-share-button", "~> 0.0.5"

# 表单
gem 'simple_form', "2.0.2"

# 用于组合小图片
gem "sprite-factory", "1.4.1", :require => false
gem 'chunky_png', "1.2.5", :require => false

# 禁用 assets 日志
gem 'quiet_assets', "1.0.1"

# API
gem 'grape', :github => 'intridea/grape', :branch => 'frontier'

# Mailer
gem 'postmark-rails', '0.4.1'

# Google Analytics performance 
gem 'garelic', '0.0.2'

group :development, :test do
  gem 'capistrano', '2.9.0', :require => false
  gem 'rvm-capistrano', :require => false
  gem "memcache-client", "1.8.5"
  gem 'rspec-rails', '~> 2.10.0'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem "rspec-cells"
  gem "capybara", :require => false
  gem 'api_taster'
  gem "letter_opener"
  gem 'thin'
end

group :production do
  gem 'dalli', '1.1.1'
  gem 'unicorn'
end
