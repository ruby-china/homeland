# frozen_string_literal: true

port 7000
environment ENV.fetch("RAILS_ENV", "production")
workers(ENV["workers"] || 4)
threads (ENV["min_threads"] || 8), (ENV["max_threads"] || 8)
preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

before_fork do
  max_memory = ((ENV["workers"] || 4).to_i + 1) * 380
  puts "=> Max Memory limit: #{max_memory}MB"
  PumaWorkerKiller.config do |config|
    config.ram = max_memory # mb
    config.percent_usage = 0.98
    config.frequency = 20 # seconds
    # config.reaper_status_logs = true # setting this to false will not log lines like:
    # PumaWorkerKiller: Consuming 54.34765625 mb with master and 2 workers.

    config.pre_term = ->(worker) { puts "Worker #{worker.inspect} being killed" }
  end
  PumaWorkerKiller.start

  ActiveRecord::Base.connection_pool.disconnect!
end

plugin :tmp_restart
