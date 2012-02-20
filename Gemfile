source 'http://ruby.taobao.org'

gem "rails", "3.2.1"
gem "rails-i18n","0.1.8"
gem "jquery-rails", "1.0.16"
gem "rails_autolink", ">= 1.0.4"

group :assets do
  gem 'sass-rails', "  ~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', '>= 1.0.3'
end

# 上传组件
gem 'carrierwave', '0.5.6'
gem 'carrierwave-mongoid', '0.1.2', :require => 'carrierwave/mongoid'
gem 'mini_magick','3.3'

# Mongoid 辅助插件
gem "mongoid", "2.4.3"
gem "bson_ext", "1.5.2"
gem 'mongo-rails-instrumentation','0.2.4'
gem 'mongoid_auto_increment_id', "0.4.0"
gem 'mongoid_rails_migrations', '~> 0.0.14'

# 用户系统
gem 'devise', '1.5.2'

# 分页
gem 'will_paginate', '3.0.2'
gem 'will_paginate_mongoid', '~> 1.0.2'
gem 'bootstrap-will_paginate', '0.0.3'

# 三方平台 OAuth 验证登陆
gem "omniauth", "~> 1.0.1"
gem 'omniauth-openid', "~> 1.0.1"
gem "omniauth-github", "~> 1.0.0"
gem "omniauth-twitter", "~> 0.0.7"
gem "omniauth-douban", :git => "git://github.com/ballantyne/omniauth-douban.git"

# permission
gem "cancan", "~> 1.6.7"

# Redis 命名空间
gem 'redis-namespace','~> 1.0.2'

# 将一些数据存放入 Redis
gem "redis-objects", "0.5.2"

# Markdown 格式
gem "redcarpet", "~> 2.0.0"
gem 'hpricot', '~> 0.8.5'
gem "pygments.rb", '~> 0.2.4'

# YAML 配置信息
gem "settingslogic", "~> 2.0.6"

gem "cells", "3.7.1"

# 队列
gem "resque", "~> 1.20.0", :require => "resque/server"
gem "resque_mailer", '2.0.2'

# AWS Simple Email Server
gem "aws-ses", "~> 0.4.3"
gem 'mail_view', :git => 'git://github.com/37signals/mail_view.git'

# 用于组合小图片
gem "sprite-factory", "1.4.1"

# 分享功能
gem "social-share-button", "~> 0.0.3"

# 表单 last commit: 2011-12-03
gem 'simple_form', :git => "git://github.com/plataformatec/simple_form.git"
gem 'bootstrap-rails', :require => 'bootstrap-rails', :git => 'git://github.com/xdite/bootstrap-rails.git'

# 全文搜索
gem 'sunspot_rails',  "~> 1.3.0"
gem 'sunspot_solr'

gem 'daemon-spawn'

# 禁用 assets 日志
gem 'quiet_assets', :git => 'git://github.com/AgilionApps/quiet_assets.git'

group :development, :test do
  gem 'capistrano', '2.9.0'
  gem 'chunky_png', "1.2.5"
  gem "memcache-client", "1.8.5"
  gem 'progress_bar'
  gem 'rspec-rails', '~> 2.8.1'
  gem 'factory_girl_rails'
	gem 'thin'
  gem "simplecov", :require => false
  gem "rspec-cells"
  gem "capybara"
  gem "sunspot-rails-tester"
end

group :production do
  gem "unicorn"
  gem 'dalli', '1.1.1'
end
