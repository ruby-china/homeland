# frozen_string_literal: true

class Reply
  module Notify
    extend ActiveSupport::Concern

    included do
      after_commit :async_create_reply_notify, on: :create, unless: -> { system_event? }
    end

    module ClassMethods
      def notify_reply_created(reply_id)
        reply = Reply.find_by_id(reply_id)
        return if reply.blank?
        return if reply.system_event?
        topic = Topic.find_by_id(reply.topic_id)
        return if topic.blank?

        Notification.bulk_insert(set_size: 100) do |worker|
          reply.notification_receiver_ids.each do |uid|
            logger.debug "Post Notification to: #{uid}"
            note = reply.send(:default_notification).merge(user_id: uid)
            worker.add(note)
          end
        end

        # Touch realtime_push_to_client
        reply.notification_receiver_ids.each do |uid|
          n = Notification.where(user_id: uid).last
          n.realtime_push_to_client if n.present?
        end
        Reply.broadcast_to_client(reply)

        true
      end

      def broadcast_to_client(reply)
        ActionCable.server.broadcast("topics/#{reply.topic_id}/replies", id: reply.id, user_id: reply.user_id, action: :create)
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

      def async_create_reply_notify
        NotifyReplyJob.perform_later(id)
      end
  end
end
