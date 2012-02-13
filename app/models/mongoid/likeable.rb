# coding: utf-8
module Mongoid
  module Likeable
    def liked_by_user?(user)
      Like.where(:likeable_type => self.class, :likeable_id => self.id, :user_id => user.id).count > 0
    end
  end
end
