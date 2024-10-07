environment ENV.fetch("RAILS_ENV", "production")
port 7001
threads 3, 3
preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

# Run the Solid Queue supervisor inside of Puma for single-server deployments
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end

plugin :tmp_restart
