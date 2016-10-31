module Likeable
  extend ActiveSupport::Concern

  included do
  end

  def liked_by_user?(user)
    return false if user.blank?
    liked_user_ids.include?(user.id)
  end

  def liked_users
    Rails.cache.fetch([self.cache_key, 'liked_users']) do
      User.find(self.liked_user_ids || [])
    end
  end
end
