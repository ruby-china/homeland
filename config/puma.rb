app_root = '/home/ruby/www/ruby-china/current'
pidfile "#{app_root}/tmp/pids/puma.pid"
state_path "#{app_root}/tmp/pids/puma.state"
daemonize true
workers 4
threads 16,64
preload_app!
