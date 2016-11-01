class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick if Setting.upload_provider == 'file'

  # 在 UpYun 或其他平台配置图片缩略图
  # http://docs.upyun.com/guide/#_12
  # Avatar
  # 固定宽度和高度
  # xs - 32x32
  # sm - 48x48
  # md - 96x96
  # lg - 192x192
  #
  # Photo
  # large - 1920x? - 限定宽度，高度自适应
  ALLOW_VERSIONS = %w(xs sm md lg large)

  def store_dir
    dir = model.class.to_s.underscore
    if Setting.upload_provider == 'file'
      dir = "uploads/#{dir}"
    end
    dir
  end

  def extension_white_list
    %w(jpg jpeg gif png svg)
  end

  def url(version_name = nil)
    @url ||= super({})
    return @url if version_name.blank?
    version_name = version_name.to_s
    unless version_name.in?(ALLOW_VERSIONS)
      raise "ImageUploader version_name:#{version_name} not allow."
    end

    case Setting.upload_provider
    when 'aliyun'
      super(thumb: "@!#{version_name}")
    when 'upyun'
      [@url, version_name].join('!')
    else
      version_name.to_sym == :large ? url : send(version_name).url
    end
  end
end
