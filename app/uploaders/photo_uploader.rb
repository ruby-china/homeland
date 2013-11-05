# coding: utf-8
class PhotoUploader < BaseUploader
  process :resize_to_limit => [680, nil]

  # Override the filename of the uploaded files:
  def filename
    if super.present?
      # current_path 是 Carrierwave 上传过程临时创建的一个文件，有时间标记，所以它将是唯一的
      # 此方法只使用 Ruby China 这类图片上传的场景
      @name ||= Digest::MD5.hexdigest(current_path)
      "#{Time.now.year}/#{@name}.#{file.extension.downcase}"
    end
  end
end
