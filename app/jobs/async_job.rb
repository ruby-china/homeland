# We use ActiveJob::QueueAdapters::AsyncAdapter for lite jobs for run queue in Rails Process as async.
# https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters/AsyncAdapter.html
class AsyncJob < ActiveJob::Base
end
