# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

# Action Cable uses EventMachine which requires that all classes are loaded in advance
Rails.application.eager_load!
# require 'action_cable/process/logging'

run Rails.application

memory_usage = (`ps -o rss= -p #{$PID}`.to_i / 1024.00).round(2)
puts "=> Memory usage: #{memory_usage} MB"
