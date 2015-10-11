require 'etc'

root = File.expand_path('../../', __FILE__)

working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen 7000, tcp_nopush: true
listen '/tmp/unicorn.ruby-china.sock', backlog: 1024
# Use number of CPU cores
worker_processes Etc.nprocessors + 1
# Because there have upload feature.
timeout 120

preload_app true
GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true

check_client_connection false

before_exec do |_server|
  ENV['BUNDLE_GEMFILE'] = "#{root}/Gemfile"
end

before_fork do |server, _worker|
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Send 'QUIT' signal to unicorn error!"
    end
  end

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
end

after_fork do |_server, _worker|
  MessageBus.after_fork

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
end
