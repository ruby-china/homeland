# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

gem "jbuilder"
gem "rails"
gem "rails_autolink"
gem "sass-rails"
gem "turbolinks"
gem "uglifier"
gem "webpacker", "~> 5.x"

gem "sanitize"

gem "pg"
gem "jieba_rb"
gem "pghero"

gem "dotenv-rails"

gem "rack-attack"

gem "http_accept_language"
gem "rails-i18n"
gem "twemoji"

# OAuth Provider
gem "doorkeeper"
gem "doorkeeper-i18n"

gem "bulk_insert"

# 上传组件
gem "carrierwave"
# Aliyun / Upyun / Qiniu 可选项
gem "carrierwave-aliyun"
gem "carrierwave-upyun"
gem "carrierwave-qiniu"

# Lazy load
gem "mini_magick", require: false

# 验证码
gem "rucaptcha"
gem "recaptcha"

# 用户系统
gem "devise"
gem "devise-encryptable"

# 通知系统
gem "notifications"
gem "ruby-push-notifications"

# 赞、关注、收藏、屏蔽等功能的数据结构
gem "action-store"

# Rails Enum 扩展
gem "enumize"

# 分页
gem "kaminari"

# 表单
gem "simple_form"

# Form select 选项
gem "form-select"

# 三方平台 OAuth 验证登录
gem "omniauth"
gem "omniauth-github"

# Permission
gem "cancancan"

# Redis
gem "redis"
gem "redis-namespace"
gem "redis-objects"

# Cache
gem "second_level_cache"

# Setting
gem "rails-settings-cached"

# HTML Pipeline
gem "auto-correct"
gem "html-pipeline"
gem "html-pipeline-auto-correct"
gem "redcarpet"
gem "rouge"

# 队列
gem "sidekiq"
gem "sidekiq-cron"

# 分享功能
gem "social-share-button"

# Mailer Service
gem "postmark"
gem "postmark-rails"

gem "puma"

# API cors
gem "rack-cors", require: "rack/cors"

gem "exception-track"

gem "bootsnap"
gem "lograge"

gem "puma_worker_killer"

group :development do
  gem "pry"
  gem 'pry-byebug'
  gem "spring"
  gem "byebug"
end

group :development, :test do
  gem "sdoc"
  gem "letter_opener"
  gem "listen"

  gem "mocha"
  gem "minitest-spec-rails"
  gem "factory_bot_rails"

  gem "rubocop", require: false
  gem "codecov", require: false
end
