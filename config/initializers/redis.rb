# frozen_string_literal: true

require "redis"
require "redis-namespace"
require "redis/objects"

redis_config = Rails.application.config_for(:redis)

$redis = Redis.new(url: redis_config["url"], driver: :hiredis, db: 0)
sidekiq_url = redis_config["url"]
Redis::Objects.redis = $redis

Sidekiq.configure_server do |config|
  config.redis = { namespace: "sidekiq", url: sidekiq_url, driver: :hiredis, db: 0 }
end
Sidekiq.configure_client do |config|
  config.redis = { namespace: "sidekiq", url: sidekiq_url, driver: :hiredis, db: 0 }
end
