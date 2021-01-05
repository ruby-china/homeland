# frozen_string_literal: true

class PhotoUploader < BaseUploader
  # Override the filename of the uploaded files:
  def filename
    if super.present?
      @name ||= SecureRandom.uuid
      "#{model.user&.login || Time.now.year}/#{@name}.#{file.extension.downcase}"
    end
  end
end
