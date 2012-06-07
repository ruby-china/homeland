require "redis"
require "redis-namespace"
require "redis/objects"

redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]

Redis::Objects.redis = Redis.new(:host => redis_config['host'], :port => redis_config['port'])