# frozen_string_literal: true

# We use ActiveJob::QueueAdapters::AsyncAdapter for lite jobs for run queue in Rails Process as async.
# https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters/AsyncAdapter.html
class AsyncJob < ActiveJob::Base
  self.queue_adapter = Rails.env.test? ? :inline : ActiveJob::QueueAdapters::AsyncAdapter.new(
    min_threads: 4,
    max_threads: 10 * Concurrent.processor_count
  )
end
