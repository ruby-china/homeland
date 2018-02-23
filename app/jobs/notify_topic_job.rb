# frozen_string_literal: true

class NotifyTopicJob < ApplicationJob
  queue_as :notifications

  def perform(topic_id)
    Topic.notify_topic_created(topic_id)
  end
end
