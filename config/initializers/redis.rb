require "redis"
require "redis-search"
require "redis-namespace"
require "redis/objects"

redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]

redis_search = Redis.new(:host => redis_config['host'],:port => redis_config['port'])
redis_search = Redis::Namespace.new(redis_config['redis_search_namespace'], :redis => redis_search)
redis_search.select("3")
Redis::Search.configure do |config|
  config.redis = redis_search
  config.complete_max_length = 30
	config.pinyin_match = true
end

Redis::Objects.redis = Redis.new(:host => redis_config['host'], :port => redis_config['port'])

require "topic"

Resque::Mailer.default_queue_name = "mailer"
Resque.redis = Redis.new(:host => redis_config['host'],:port => redis_config['port'])
Resque.redis.namespace = "resque:ruby-china"