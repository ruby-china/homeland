# frozen_string_literal: true

require "redis"
require "redis-namespace"
require "redis/objects"

redis_config = Rails.application.config_for(:redis)

if redis_config["url"]
  $redis = Redis.new(url: redis_config["host"], driver: :hiredis)
  sidekiq_url = redis_config["url"]
else
  $redis = Redis.new(host: redis_config["host"], port: redis_config["port"], driver: :hiredis)
  $redis.select(0)
  sidekiq_url = "redis://#{redis_config['host']}:#{redis_config['port']}/0"
end
Redis::Objects.redis = $redis


Sidekiq.configure_server do |config|
  config.redis = { namespace: "sidekiq", url: sidekiq_url, driver: :hiredis }
end
Sidekiq.configure_client do |config|
  config.redis = { namespace: "sidekiq", url: sidekiq_url, driver: :hiredis }
end
