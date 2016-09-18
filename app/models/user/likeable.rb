class User
  module Likeable
    extend ActiveSupport::Concern

    # 赞
    def like(likeable)
      return false if likeable.blank?
      return false if liked?(likeable)
      likeable.transaction do
        likeable.push(liked_user_ids: id)
        likeable.increment!(:likes_count)
      end
    end

    # 取消赞
    def unlike(likeable)
      return false if likeable.blank?
      return false unless liked?(likeable)
      return false if likeable.user_id == self.id
      likeable.transaction do
        likeable.pull(liked_user_ids: id)
        likeable.decrement!(:likes_count)
      end
    end

    # 是否喜欢过
    def liked?(likeable)
      likeable.liked_by_user?(self) || likeable.user_id == self.id
    end
  end
end
