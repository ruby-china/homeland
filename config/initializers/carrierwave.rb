require 'carrierwave'
require 'carrierwave/validations/active_model'

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

CarrierWave.configure do |config|
  if Rails.env.test?
    # http://stackoverflow.com/questions/7534341/rails-3-test-fixtures-with-carrierwave/25315883#25315883
    config.storage NullStorage
  else
    config.storage = :upyun
  end
  # Do not remove previously file after new file uploaded
  config.remove_previously_stored_files_after_update = false
  config.upyun_username = Setting.upyun_username
  config.upyun_password = Setting.upyun_password
  config.upyun_bucket = Setting.upyun_bucket
  config.upyun_bucket_host = Setting.upload_url
end
