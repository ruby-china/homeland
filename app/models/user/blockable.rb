class User
  module Blockable
    extend ActiveSupport::Concern

    def block_node(node_id)
      node_id = node_id.to_i
      return false if blocked_node_ids.include?(node_id)
      push(blocked_node_ids: node_id)
    end

    def unblock_node(node_id)
      pull(blocked_node_ids: node_id.to_i)
    end

    def blocked_users?
      blocked_user_ids.count > 0
    end

    def blocked_user?(user)
      uid = user.is_a?(User) ? user.id : user
      blocked_user_ids.include?(uid)
    end

    def block_user(user_id)
      user_id = user_id.to_i
      return false if self.blocked_user?(user_id)
      push(blocked_user_ids: user_id)
    end

    def unblock_user(user_id)
      pull(blocked_user_ids: user_id.to_i)
    end
  end
end
