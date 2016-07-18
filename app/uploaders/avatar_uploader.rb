class AvatarUploader < BaseUploader
  def filename
    if super.present?
      "avatar/#{model.id}.jpg"
    end
  end
end
