app_root = '/home/appr/homeland'
daemonize false
environment ENV.fetch("RAILS_ENV") { "production" }
port 7001
workers 1
threads (ENV["min_threads"] || 8), (ENV["max_threads"] || 8)
preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end
