# frozen_string_literal: true

class AvatarUploader < BaseUploader
  def filename
    if super.present?
      @name ||= SecureRandom.hex(3)
      "avatar/#{model.id}/#{@name}.#{file.extension.downcase}"
    end
  end
end
