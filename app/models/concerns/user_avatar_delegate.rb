# frozen_string_literal: true

module UserAvatarDelegate
  extend ActiveSupport::Concern

  def user_avatar_raw
    user ? user[:avatar] : nil
  end
end
