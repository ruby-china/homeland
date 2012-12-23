class Setup < Thor::Group
  include Thor::Actions

  desc "Bootstrap development environment"
  source_root File.expand_path('../../..', __FILE__)

  def start
    say "Now Installing Ruby China..."
    say_ruler '='
    puts
  end

  def check_package_dependencies
    say_section 'Checking Package Dependencies...' do
      pkg_exist = true
      [["bundle","Bundler"],["python","Python 2.5+"],["pygmentize","Pygments 1.5+"],["mongod","MongoDB 2.0+"],["redis-server","Redis 2.0+"],["memcached","Memcached 1.4+"],["convert","ImageMagick 6.5+"]].each do |(executable, name)|
        if system("which #{executable} &> /dev/null")
          say_status 'FOUND', name, :green
        else
          say_status 'MISSING', name, :red
          pkg_exist = false
        end
      end

      if pkg_exist == false
        exit(1) unless yes?("I'll fix these later, let me continue (Y/n): ")
      end
    end
  end

  def create_config_files
    say_section "Configure" do
      copy_file 'config/config.yml.default', 'config/config.yml'
      copy_file 'config/thin.yml.default', 'config/thin.yml'
      copy_file 'config/newrelic.yml.default', 'config/newrelic.yml'

      host = ask_with_default('You MongoDB host', '127.0.0.1:27017')

      mongoid_config = File.read('config/mongoid.yml.default')
      mongoid_config.gsub!('SETUP_DEVELOPMENT_HOST', host)

      create_file('config/mongoid.yml', mongoid_config)

      host_port = ask_with_default('You Redis host', '127.0.0.1:6379')
      host, port = host_port.split(':')
      port ||= '6379'

      redis_config = File.read('config/redis.yml.default')
      redis_config.gsub!('SETUP_REDIS_HOST', host)
      redis_config.gsub!('SETUP_REDIS_PORT', port)

      create_file('config/redis.yml', redis_config)
    end
  end

  def bundle_install
    run_or_exit 'bundle install'
  end

  def db_seed
    run_or_exit 'bundle exec rake db:seed'
  end

  def finish
    puts ""
    say "Ruby China Successfully Installed.", :green
  end

  no_tasks do
    def say_section(*args)
      say *args
      say_ruler
      yield
      say_ruler
      puts
    end

    def say_ruler(char = '-')
      say char * terminal_width
    end

    def ask_with_default(message, default, *args)
      answer = ask(message + " (#{default})", *args)
      answer.empty? ? default : answer
    end

    def run_or_exit(*args)
      run *args
      if $? && $?.exitstatus != 0
        say_status "FAILED", args.first, :red
        exit(1)
      end
    end
  end
end

