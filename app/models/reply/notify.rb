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

    def private_org_notification_receiver_ids
      return @private_org_notification_receiver_ids if defined? @private_org_notification_receiver_ids
      if topic.private_org
        follower_ids = self.topic&.team.team_notify_users.pluck(:user_id) || []
        # 排除回帖人
        follower_ids.delete(self.user_id)
        @private_org_notification_receiver_ids = follower_ids
      else
        @private_org_notification_receiver_ids = []
      end
    end

    def notification_receiver_ids
      return @notification_receiver_ids if defined? @notification_receiver_ids
      # 加入帖子关注着
      follower_ids = self.topic.try(:follow_by_user_ids) || []
      # 加入回帖人的关注者
      follower_ids += self.user.try(:follow_by_user_ids) || []
      # 加入发帖人
      follower_ids << self.topic.try(:user_id)
      # 去重复
      follower_ids.uniq!
      # 排除回帖人
      follower_ids.delete(self.user_id)
      # 排除同一个回复过程中已经提醒过的人
      follower_ids -= self.mentioned_user_ids
      @notification_receiver_ids = follower_ids
    end

    private
      def default_notification
        @default_notification ||= {
          notify_type: "topic_reply",
          target_type: "Reply",
          target_id: self.id,
          second_target_type: "Topic",
          second_target_id: self.topic_id,
          actor_id: self.user_id
        }
      end
  end
end
