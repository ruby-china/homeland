RAILS_ROOT = "/home/ruby/www/ruby-china/current"

God.watch do |w|
  w.name     = "sidekiq"
  w.interval = 30.seconds
  w.dir      = RAILS_ROOT
  w.pid_file = "#{RAILS_ROOT}/tmp/pids/#{w.name}.pid"
  w.start    = "nohup bundle exec sidekiq -e production -C config/sidekiq.yml -P tmp/pids/sidekiq.pid >> #{RAILS_ROOT}/log/sidekiq.log 2>&1 &"
  w.stop     = "kill -9 `cat #{RAILS_ROOT}/tmp/pids/sidekiq.pid`"
  
  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end

God.watch do |w|
  w.name = "faya"
  w.interval = 30.seconds
  w.dir = [RAILS_ROOT, "faye_server"].join("/")
  w.pid_file = "#{RAILS_ROOT}/tmp/pids/thin.6000.pid"
  w.start = "bundle exec thin start -C thin.yml"
  w.stop = "kill -9 `cat #{RAILS_ROOT}/tmp/pids/thin.6000.pid`"
  
  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end