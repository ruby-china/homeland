# frozen_string_literal: true

class User
  module Avatar
    extend ActiveSupport::Concern

    LETTER_AVATAR_REGEXP = /([a-z0-9])/i

    included do
      mount_uploader :avatar, AvatarUploader

      define_method :avatar? do
        self[:avatar].present?
      end
    end

    def large_avatar_url
      if self[:avatar].present?
        self.avatar.url(:lg)
      else
        self.letter_avatar_url(192)
      end
    end

    def letter_avatar_char
      matchs = LETTER_AVATAR_REGEXP.match(login)
      (matchs[0] || "-").downcase
    end

    def letter_avatar_url(size)
      return nil if login.blank?

      avatar_path = File.join("letter_avatars", letter_avatar_char + ".png")

      "#{Setting.base_url}/system/#{avatar_path}"
    end
  end
end
