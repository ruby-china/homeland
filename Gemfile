# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

gem "jbuilder"
gem "rails", "~> 7.0"
gem "rails_autolink"
gem "sass-rails"
gem "turbolinks"
gem "uglifier"
gem "shakapacker"

gem "view_component"

gem "pg"

gem "devise"
gem "devise-encryptable"
gem "cancancan"
gem "doorkeeper"
gem "doorkeeper-i18n"
gem "omniauth", "~> 1.x"
gem "omniauth-github"
gem "omniauth-twitter"
gem "omniauth-wechat-oauth2"
gem "omniauth-rails_csrf_protection"

gem "jieba-rb"
gem "dotenv-rails"

gem "rack-attack"
gem "http_accept_language"
gem "rails-i18n"
gem "twemoji"

# Uploader
gem "carrierwave"
# Aliyun / Upyun / Qiniu
gem "carrierwave-aliyun"
gem "carrierwave-upyun"
gem "faraday", "~> 1.10" # upyun not ready for new version
gem "carrierwave-qiniu"
gem "qiniu"

gem "mini_magick", require: false

# Captcha
gem "rucaptcha"
gem "recaptcha"

# Notification
gem "notifications"
gem "ruby-push-notifications"

gem "action-store"

gem "kaminari"
gem "form-select"
gem "enumize"

gem "pghero"
gem "exception-track"

# Cache
gem "redis"
gem "redis-namespace"
gem "second_level_cache"

# Setting
gem "rails-settings-cached"

# HTML Pipeline
gem "auto-correct"
gem "html-pipeline"
gem "html-pipeline-auto-correct"
gem "redcarpet"
gem "rouge"

gem "sidekiq"
gem "sidekiq-cron"

gem "social-share-button"

# Mailer Service
gem "postmark"
gem "postmark-rails"

gem "puma"

# API cors
gem "rack-cors", require: "rack/cors"

gem "bootsnap"

gem "puma_worker_killer"

group :development do
  gem "spring"
  gem "byebug"
  gem "letter_opener"
end

group :development, :test do
  gem "listen"

  gem "mocha"
  gem "minitest-spec-rails"
  gem "factory_bot_rails"

  gem "standard"
end

gem "connection_pool", "~> 2.2"
