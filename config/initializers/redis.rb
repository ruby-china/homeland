require "redis"
require "redis-namespace"
require "redis/objects"
require 'sidekiq/middleware/client/unique_jobs'
require 'sidekiq/middleware/server/unique_jobs'

redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]

Redis::Objects.redis = Redis.new(:host => redis_config['host'], :port => redis_config['port'])

sidekiq_url = "redis://#{redis_config['host']}:#{redis_config['port']}/0"
Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'sidekiq', :url => sidekiq_url }
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::UniqueJobs
  end
end
Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'sidekiq', :url => sidekiq_url }
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::UniqueJobs
  end
end