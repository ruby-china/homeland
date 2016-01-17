module Concerns
    module Likeable
    extend ActiveSupport::Concern

    included do
    end

    def liked_by_user?(user)
      return false if user.blank?
      liked_user_ids.include?(user.id)
    end
  end
end
