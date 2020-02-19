# frozen_string_literal: true

require "redis"
require "redis-namespace"
require "redis/objects"

redis_config = Rails.application.config_for(:redis)

$redis = Redis.new(url: redis_config["url"], db: 0)
sidekiq_url = redis_config["url"]
Redis::Objects.redis = $redis

Sidekiq.configure_server do |config|
  config.redis = { namespace: "sidekiq", url: sidekiq_url, db: 0 }
end
Sidekiq.configure_client do |config|
  config.redis = { namespace: "sidekiq", url: sidekiq_url, db: 0 }
end

if Sidekiq.server?
  schedule_config = YAML.load(ERB.new(File.read("config/schedule.yml")).result)
  Sidekiq::Cron::Job.load_from_hash(schedule_config)
end
