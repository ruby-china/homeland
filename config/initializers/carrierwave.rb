# frozen_string_literal: true

require "carrierwave"
require "carrierwave/validations/active_model"

class NullStorage
  attr_reader :uploader

  def initialize(uploader)
    @uploader = uploader
  end

  def identifier
    uploader.filename
  end

  def store!(_file)
    true
  end

  def retrieve!(_identifier)
    true
  end
end

Rails.application.config.to_prepare do
  CarrierWave.configure do |config|
    # http://stackoverflow.com/questions/7534341/rails-3-test-fixtures-with-carrierwave/25315883#25315883
    config.storage NullStorage if Rails.env.test?

    case Setting.upload_provider
    when "aliyun"
      config.storage = :aliyun
      config.aliyun_access_key_id = Setting.upload_access_id
      config.aliyun_access_key_secret = Setting.upload_access_secret
      config.aliyun_bucket = Setting.upload_bucket
      config.aliyun_internal = Setting.upload_aliyun_internal.to_s != "false"
      config.aliyun_region = Setting.upload_aliyun_region
      if Setting.upload_url.present?
        config.aliyun_host = Setting.upload_url
      end
    when "upyun"
      config.storage = :upyun
      # Do not remove previously file after new file uploaded
      config.remove_previously_stored_files_after_update = false
      config.upyun_username = Setting.upload_access_id
      config.upyun_password = Setting.upload_access_secret
      config.upyun_bucket = Setting.upload_bucket
      config.upyun_bucket_host = Setting.upload_url
    when "qiniu"
      config.storage = :qiniu
      config.qiniu_access_key = Setting.upload_access_id
      config.qiniu_secret_key = Setting.upload_access_secret
      config.qiniu_bucket = Setting.upload_bucket
      config.qiniu_protocol = Setting.upload_url.split("://")[0]
      config.qiniu_bucket_domain = Setting.upload_url.split("://")[1]
    else
      config.storage = :file
    end
  end
end
