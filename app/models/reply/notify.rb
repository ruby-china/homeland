# frozen_string_literal: true

class Reply
  module Notify
    extend ActiveSupport::Concern

    included do
      after_commit on: :create, unless: -> { system_event? } do
        NotifyReplyJob.perform_later(id)
      end
    end

    def broadcast_to_client
      message = { id: self.id, user_id: self.user_id, action: :create }
      ActionCable.server.broadcast("topics/#{self.topic_id}/replies", message)
    end

    def notification_receiver_ids
      return @notification_receiver_ids if defined? @notification_receiver_ids
      # Topic followers
      follower_ids = self.topic.try(:follow_by_user_ids) || []
      # Reply user's followers
      follower_ids += self.user.try(:follow_by_user_ids) || []
      # Topic creator
      follower_ids << self.topic.try(:user_id)
      follower_ids.uniq!
      # Exclude reply user
      follower_ids.delete(self.user_id)
      # Exclude people who have been notified during the same reply
      follower_ids -= self.mentioned_user_ids
      @notification_receiver_ids = follower_ids
    end

    def default_notification
      @default_notification ||= {
        notify_type: "topic_reply",
        target_type: "Reply",
        target_id: self.id,
        second_target_type: "Topic",
        second_target_id: self.topic_id,
        actor_id: self.user_id,
        created_at: Time.now,
        updated_at: Time.now
      }
    end
  end
end
