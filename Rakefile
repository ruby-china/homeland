# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'resque/tasks'

RubyChina::Application.load_tasks

namespace :resque do
  task :restart_workers => :environment do
    pids = Array.new

    Resque.workers.each do |worker|
      pids << worker.to_s.split(/:/).second
    end

    if pids.size > 0
      system("kill -QUIT #{pids.join(' ')}")
    end

    system("rm /var/run/god/resque-1.8.0*.pid")
  end
end

namespace :test do
  desc "preparing config files..."
  task :prepare => :init do
    ["config","mongoid","redis"].each do |cfgfile|
      system("cp config/#{cfgfile}.yml.default config/#{cfgfile}.yml") unless File.exist?("config/#{cfgfile}.yml")
    end
  end

  desc "start essential services.."
  task :init do
    desc "starting resque..."
    system("./script/resque start")
    desc "starting sunspot..."
    system("bundle exec rake sunspot:solr:start")
  end
end
