require 'ftp_sync'
namespace :assets do
  desc 'sync assets to cdns'
  task cdn: :environment do
    # 排除 10 分钟以前创建的 assets 文件
    new_assets = Dir['public/assets/*'].reject do |f|
      t = File.ctime(f).to_i
      (Time.now.to_i - t) >= 600
    end

    if new_assets.length > 0
      ftp = FtpSync.new('v1.ftp.upyun.com',
                        [Setting.upyun_username, Setting.upyun_bucket].join('/'),
                        Setting.upyun_password,
                        true)
      ftp.sync("#{Rails.root}/public/assets/", '/assets')
    else
      puts "Not found new assets file cdn sync skiped."
    end
  end
end
