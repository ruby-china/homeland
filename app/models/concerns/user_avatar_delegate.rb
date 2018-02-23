# frozen_string_literal: true

module UserAvatarDelegate
  extend ActiveSupport::Concern

  def user_avatar_raw
    self.user ? self.user[:avatar] : nil
  end
end
