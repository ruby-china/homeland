class AvatarUploader < BaseUploader
  if Setting.upload_provider == 'file'
    version :xs do
      process resize_to_fill: [32, 32]
    end

    version :sm do
      process resize_to_fill: [48, 48]
    end

    version :md do
      process resize_to_fill: [96, 96]
    end

    version :lg do
      process resize_to_fill: [192, 192]
    end
  end

  def filename
    if super.present?
      "avatar/#{model.id}.jpg"
    end
  end
end
