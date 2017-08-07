class User
  module Blockable
    extend ActiveSupport::Concern

    included do
      action_store :block, :user
      action_store :block, :node
    end

    def block_users?
      block_user_actions.first.present?
    end
  end
end
