redis_config = Rails.application.config_for(:redis)

StatusPage.configure do
  use :cache
  use :redis, url: "redis://#{redis_config['host']}:#{redis_config['port']}/0"
  use :sidekiq
  use :database

  interval = 10
end
