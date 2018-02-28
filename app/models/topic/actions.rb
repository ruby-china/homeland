# frozen_string_literal: true

class Topic
  module Actions
    extend ActiveSupport::Concern

    # 删除并记录删除人
    def destroy_by(user)
      return false if user.blank?
      update_attribute(:who_deleted, user.login)
      destroy
    end

    def destroy
      super
      delete_notification_mentions
    end

    def ban!(reason: "")
      transaction do
        update!(lock_node: true, node_id: Node.no_point.id, admin_editing: true)
        if reason
          Reply.create_system_event!(action: "ban", topic_id: self.id, body: reason)
        end
      end
    end

    def excellent!
      transaction do
        Reply.create_system_event!(action: "excellent", topic_id: self.id)
        update!(excellent: 1)
      end
    end

    def unexcellent!
      transaction do
        Reply.create_system_event!(action: "unexcellent", topic_id: self.id)
        update!(excellent: 0)
      end
    end

    def excellent?
      excellent >= 1
    end
  end
end
