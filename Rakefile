# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

RubyChina::Application.load_tasks

namespace :test do
  desc "preparing config files..."
  task :prepare => :init do
    ["config","mongoid","redis"].each do |cfgfile|
      system("cp config/#{cfgfile}.yml.default config/#{cfgfile}.yml") unless File.exist?("config/#{cfgfile}.yml")
    end
  end

  desc "start essential services.."
  task :init do
    system("bundle exec rake sunspot:solr:start")
  end
end
