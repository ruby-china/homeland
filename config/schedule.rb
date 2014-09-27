# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every 1.hours do
  runner "Topic.update_daily_hot_topics"
end

every 7.days do
  runner "Topic.update_weekly_hot_topics"
end

# Learn more: http://github.com/javan/whenever
