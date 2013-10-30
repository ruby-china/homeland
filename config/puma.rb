APP_ROOT = '/home/ruby/www/ruby-china/current'
pidfile "#{APP_ROOT}/tmp/pids/puma.pid"
state_path "#{APP_ROOT}/tmp/pids/puma.state"
daemonize true
workers 4
threads 8,32
preload_app!

