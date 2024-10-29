return if ENV["RAILS_PRECOMPILE"]

redis_config = Rails.application.config_for(:redis)
sidekiq_url = redis_config["url"]

Sidekiq.configure_server do |config|
  config.redis = { url: sidekiq_url, db: 1 }
end
Sidekiq.configure_client do |config|
  config.redis = { url: sidekiq_url, db: 1 }
end

if Sidekiq.server?
  schedule_config = YAML.safe_load(ERB.new(File.read("config/schedule.yml")).result)
  Sidekiq::Cron::Job.load_from_hash(schedule_config)
end
