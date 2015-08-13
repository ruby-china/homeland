require 'rack-mini-profiler'

redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]

Rack::MiniProfilerRails.initialize!(Rails.application)
Rack::MiniProfiler.config.storage_options = { host: redis_config['host'], port: redis_config['port'] }
Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
