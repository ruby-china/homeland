module Likeable
  def self.included(base)
    base.class_eval { include InstanceMethods }
  end

  module InstanceMethods
    def liked_by_user?(user)
      Like.where(:likeable_type => self.class, :likeable_id => self.id, :user_id => user.id).count > 0
    end
  end
end