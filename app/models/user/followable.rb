class User
  module Followable
    extend ActiveSupport::Concern

    def following
      User.where(id: self.following_ids)
    end

    def followers
      User.where(id: self.follower_ids)
    end

    def followed?(user)
      uid = user.is_a?(User) ? user.id : user
      following_ids.include?(uid)
    end

    def follow_user(user)
      return unless user
      self.transaction do
        self.push(following_ids: user.id)
        user.push(follower_ids: self.id)
      end
      Notification.notify_follow(user.id, self.id)
    end

    def followers_count
      follower_ids.count
    end

    def following_count
      following_ids.count
    end

    def unfollow_user(user)
      return unless user
      self.transaction do
        self.pull(following_ids: user.id)
        user.pull(follower_ids: self.id)
      end
    end
  end
end
