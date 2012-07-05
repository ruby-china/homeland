require 'sidekiq/middleware/client/unique_jobs'
require 'sidekiq/middleware/server/unique_jobs'
Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'sidekiq' }
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::UniqueJobs
  end
end

Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'sidekiq' }
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::UniqueJobs
  end
end