require 'ftp_sync'
namespace :assets do
  desc 'sync assets to cdns'
  task cdn: :environment do 
    ftp = FtpSync.new("v1.ftp.upyun.com", [Setting.upyun_username,Setting.upyun_bucket].join("/"), Setting.upyun_password,true)
    ftp.sync("#{Rails.root}/public/assets/", "/assets")
  end
end
