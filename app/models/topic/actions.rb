# frozen_string_literal: true

class Topic
  module Actions
    extend ActiveSupport::Concern

    included do
      enum grade: {ban: -1, normal: 0, excellent: 1}

      # Follow enum method override methods must in `included` block.

      def ban!(reason: "")
        transaction do
          update!(grade: :ban)
          if reason
            Reply.create_system_event!(action: "ban", topic_id: id, body: reason)
          end
        end
      end

      def excellent!
        transaction do
          Reply.create_system_event!(action: "excellent", topic_id: id)
          update!(grade: :excellent)
        end
      end

      def unexcellent!
        transaction do
          Reply.create_system_event!(action: "unexcellent", topic_id: id)
          update!(grade: :normal)
        end
      end
    end

    # Destroy record, and then log who deleted.
    def destroy_by(user)
      return false if user.blank?
      update_attribute(:who_deleted, user.login)
      destroy
    end

    def destroy
      super
      delete_notification_mentions
    end
  end
end
