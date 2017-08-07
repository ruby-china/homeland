class PhotoUploader < BaseUploader
  # Override the filename of the uploaded files:
  def filename
    if super.present?
      @name ||= SecureRandom.uuid
      "#{Time.now.year}/#{@name}.#{file.extension.downcase}"
    end
  end
end
