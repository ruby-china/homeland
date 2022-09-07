# frozen_string_literal: true

return if ENV["RAILS_PRECOMPILE"]

redis_config = Rails.application.config_for(:redis)

Redis.current = Redis.new(url: redis_config["url"], db: 0)
sidekiq_url = redis_config["url"]

# Sidekiq require redis-namespace gem
require "redis-namespace"
Sidekiq.configure_server do |config|
  config.redis = {namespace: "sidekiq", url: sidekiq_url, db: 0}
end
Sidekiq.configure_client do |config|
  config.redis = {namespace: "sidekiq", url: sidekiq_url, db: 0}
end

if Sidekiq.server?
  schedule_config = YAML.safe_load(ERB.new(File.read("config/schedule.yml")).result)
  Sidekiq::Cron::Job.load_from_hash(schedule_config)
end

SecondLevelCache.configure.cache_key_prefix = "slc:3"

# FIXME: Upgrade redis-objects then remove this line.
# `Redis#exists(key)` will return an Integer in redis-rb 4.3. `exists?` returns a boolean,
# you should use it instead. To opt-in to the new behavior now you can set
# Redis.exists_returns_integer =  true. To disable this message and keep the current (boolean) behaviour of 'exists'
# you can set `Redis.exists_returns_integer = false`, but this option will be removed in 5.0.
# Redis.exists_returns_integer = false
