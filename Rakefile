# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

Rails.application.load_tasks

namespace :test do
  desc "preparing config files..."
  task :prepare => :init do
    ["config","mongoid","redis"].each do |cfgfile|
      system("cp config/#{cfgfile}.yml.default config/#{cfgfile}.yml") unless File.exist?("config/#{cfgfile}.yml")
    end
  end
end
