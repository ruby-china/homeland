if ENV['TRAVIS']
  source 'https://rubygems.org'
else
  source 'https://gems.ruby-china.org'
end

gem 'rails', '~> 5.1.0'
gem 'sprockets'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'jbuilder'
gem 'turbolinks', '~> 5.0.0'
gem 'dropzonejs-rails'
gem 'rails_autolink'

gem 'sanitize'

gem 'pg'
gem 'pghero'

gem 'rack-attack'

gem 'rails-i18n'
gem 'http_accept_language'
gem 'twemoji'
gem 'jquery-atwho-rails'
gem 'font-awesome-rails'

# OAuth Provider
gem 'doorkeeper'
gem 'doorkeeper-i18n'

gem 'bulk_insert'

# 上传组件
gem 'carrierwave'
# Aliyun / Upyun 可选项
gem 'carrierwave-upyun'
gem 'carrierwave-aliyun'
# Lazy load
gem 'mini_magick', require: false

# 验证码，头像
gem 'rucaptcha'
gem 'letter_avatar'

# 用户系统
gem 'devise'
gem 'devise-encryptable'

# 通知系统
gem 'notifications'
gem 'ruby-push-notifications'

# 赞、关注、收藏、屏蔽等功能的数据结构
gem 'action-store'

# 分页
gem 'kaminari'

# 搜索
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'elasticsearch-persistence'

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

# HTML Pipeline
gem 'html-pipeline'
gem 'html-pipeline-rouge_filter'
gem 'redcarpet'
gem 'auto-space'

# 队列
gem 'sidekiq'

# 分享功能
gem 'social-share-button'

# 表单
gem 'simple_form'

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

gem 'whenever', require: false

gem 'exception-track'
gem 'status-page'

gem 'bundler-audit', require: false

# Homeland Plugins
gem 'homeland-press'
gem 'homeland-jobs'
gem 'homeland-wiki'
gem 'homeland-note'
gem 'homeland-site'

gem 'sdoc', '~> 1.0.0.rc3'

group :development do
  gem 'derailed'
  # Better Errors
  gem 'better_errors'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'pry-rails'
end

group :development, :test do
  gem 'listen'
  gem 'rubocop', '0.47.1', require: false
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'letter_opener'
  gem 'yard'

  gem 'codecov', require: false
end
