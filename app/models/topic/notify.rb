# frozen_string_literal: true

class Topic
  module Notify
    extend ActiveSupport::Concern

    included do
      before_save :notify_admin_editing_node_changed
      after_commit :async_create_reply_notification, on: :create
    end

    module ClassMethods
      def notify_topic_created(topic_id)
        topic = Topic.find_by_id(topic_id)
        return unless topic&.user

        follower_ids = topic.user.follow_by_user_ids
        return if follower_ids.empty?

        notified_user_ids = topic.mentioned_user_ids

        # 给关注者发通知
        default_note = { notify_type: "topic", target_type: "Topic", target_id: topic.id, actor_id: topic.user_id }
        Notification.bulk_insert(set_size: 100) do |worker|
          follower_ids.each do |uid|
            # 排除同一个回复过程中已经提醒过的人
            next if notified_user_ids.include?(uid)
            # 排除回帖人
            next if uid == topic.user_id
            note = default_note.merge(user_id: uid)
            worker.add(note)
          end
        end

        true
      end

      def notify_topic_node_changed(topic_id, node_id)
        topic = Topic.find_by_id(topic_id)
        return if topic.blank?
        node = Node.find_by_id(node_id)
        return if node.blank?

        Notification.create! notify_type: "node_changed", user_id: topic.user_id, target: topic, second_target: node
        true
      end
    end

    private
      def notify_admin_editing_node_changed
        return unless self.node_id_changed?

        if Current.user&.admin? || Current.user&.maintainer?
          Topic.notify_topic_node_changed(id, node_id)
        end
      end

      def async_create_reply_notification
        NotifyTopicJob.perform_later(id)
      end
  end
end
