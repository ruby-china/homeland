# coding: utf-8
module Mongoid
  module Likeable
    extend ActiveSupport::Concern

    included do
      field :liked_user_ids, type: Array, default: []
      field :likes_count, type: Integer, default: 0
    end

    def liked_by_user?(user)
      return false if user.blank?
      liked_user_ids.include?(user.id)
    end
  end
end
