# frozen_string_literal: true

redis_config = Rails.application.config_for(:redis)

StatusPage.configure do
  use :cache
  use :redis, url: redis_config["url"]
  use :sidekiq
  use :database

  interval = 10
end
