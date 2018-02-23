# frozen_string_literal: true

class NotifyReplyJob < ApplicationJob
  queue_as :notifications

  def perform(reply_id)
    Reply.notify_reply_created(reply_id)
  end
end
