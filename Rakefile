#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task default: 'bundle:audit'

if Rails.env.development?
  require 'derailed_benchmarks'
  require 'derailed_benchmarks/tasks'
end

namespace :test do
  desc 'preparing config files...'
  task :prepare do
    %w(config mongoid redis).each do |cfgfile|
      system("cp config/#{cfgfile}.yml.default config/#{cfgfile}.yml") unless File.exist?("config/#{cfgfile}.yml")
    end
  end
end

