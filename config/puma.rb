app_root = '/home/ruby/www/ruby-china/current'
pidfile "#{app_root}/tmp/pids/puma.pid"
state_path "#{app_root}/tmp/pids/puma.state"
bind "unix:/tmp/unicorn.ruby-china.sock"
daemonize true
port 7000
workers 4
threads 8,16
preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
