# frozen_string_literal: true

app_root = "/home/app/homeland"
daemonize false
port 7000
environment ENV.fetch("RAILS_ENV") { "production" }
workers (ENV["workers"] || 4)
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

plugin :tmp_restart
