require "redis-search"
redis_search = Redis.new(:host => "127.0.0.1",:port => "6379")
# change redis database to 3, you need use a special database for search feature.
redis_search.select(3)
Redis::Search.configure do |config|
  config.redis = redis_search
  config.complete_max_length = 100
end

require "topic"