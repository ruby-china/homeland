namespace :assets do
  desc 'sync assets to cdns'
  task cdn: :environment do
    # 排除 24 小时以前创建的 assets 文件
    new_assets = Dir['public/assets/**/*'].reject do |f|
      t = File.ctime(f).to_i
      (Time.now.to_i - t) >= (24 * 60 * 60)
    end

    if new_assets.length > 0
      require 'upyun'
      upyun = Upyun::Rest.new(Setting.upyun_bucket, Setting.upyun_username, Setting.upyun_password)
      puts "Will upload #{new_assets.length} assets to UpYun..."
      new_assets.each do |filename|
        file_key = filename.gsub(/^public\//, '/')

        # 跳过目录
        real_filename = Rails.root.join(filename)
        if !File.file?(real_filename)
          next
        end

        # 跳过已存在的文件
        info = upyun.getinfo(file_key)
        if info[:file_size] != nil
          next
        end

        print "=> #{file_key}"
        res = upyun.put(file_key, File.new(real_filename))
        if res == true || res[:width] != nil
          puts " [Ok]"
        else
          puts " [Failed] #{res.inspect}"
        end
      end
    else
      puts "Not found new assets file cdn sync skiped."
    end
  end
end
