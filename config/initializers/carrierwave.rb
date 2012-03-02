CarrierWave.configure do |config|
  config.storage = :upyun
  config.upyun_username = Setting.upyun_username
  config.upyun_password = Setting.upyun_password
  config.upyun_bucket = Setting.upyun_bucket
  config.upyun_bucket_domain = Setting.upload_url.gsub("http://","")
end
