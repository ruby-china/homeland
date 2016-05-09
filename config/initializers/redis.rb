require 'redis'
require 'redis-namespace'
require 'redis/objects'
require 'ruby-pinyin'

redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]

$redis = Redis.new(host: redis_config['host'], port: redis_config['port'])
Redis::Objects.redis = $redis

sidekiq_url = "redis://#{redis_config['host']}:#{redis_config['port']}/0"
Sidekiq.configure_server do |config|
  config.redis = { namespace: 'sidekiq', url: sidekiq_url }
end
Sidekiq.configure_client do |config|
  config.redis = { namespace: 'sidekiq', url: sidekiq_url }
end

# Redis Search
PinYin.backend = PinYin::Backend::Simple.new
redis_for_search = Redis::Namespace.new("rc-rs", redis: $redis)
redis_for_search.select(2)
Redis::Search.configure do |config|
  config.redis = redis_for_search
  config.complete_max_length = 100
  config.pinyin_match = true
end
