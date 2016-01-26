require 'rack-mini-profiler'

if !Rails.env.test?
  redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]

  Rack::MiniProfilerRails.initialize!(Rails.application)
  Rack::MiniProfiler.config.storage_options = { host: redis_config['host'], port: redis_config['port'] }
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
  Rack::MiniProfiler.config.disable_env_dump = true
  Rack::MiniProfiler.config.skip_paths = ['/message-bus']
end
