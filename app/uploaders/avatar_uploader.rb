class AvatarUploader < BaseUploader
  def filename
    if super.present?
      @name ||= Digest::MD5.hexdigest(current_path)
      "avatar/#{@name}.#{file.extension.downcase}"
    end
  end
end
