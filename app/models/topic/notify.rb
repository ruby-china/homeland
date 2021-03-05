# frozen_string_literal: true

class Topic
  module Notify
    extend ActiveSupport::Concern

    included do
      before_save :notify_admin_editing_node_changed
      after_commit on: :create do
        NotifyTopicJob.perform_later(id)
      end
    end

    private

    def notify_admin_editing_node_changed
      return unless node_id_changed?

      if Current.user&.admin? || Current.user&.maintainer?
        NotifyTopicNodeChangedJob.perform_later(id, node_id: node_id)
      end
    end
  end
end
