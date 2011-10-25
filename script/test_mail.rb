#!/usr/bin/env ruby
require File.expand_path('../../config/environment.rb', __FILE__)

@config = YAML.load_file("#{Rails.root}/config/mailer_daemon.yml")
@config = @config[Rails.env].to_options

@sleep_time = @config.delete(:sleep_time) || 30

puts "Starting MailerDaemonFetcherDaemon"
# Add your own receiver object below
@fetcher = Fetcher.create({:receiver => WatchMailer}.merge(@config))

loop do
  s = @fetcher.fetch
  s = nil
  sleep(@sleep_time)
end