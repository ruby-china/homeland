class GenerateUserEmailMd5< Mongoid::Migration
  def self.up
    User.all.each do |u|
      u.set(:email_md5 => Digest::MD5.hexdigest(u.email || ""))
    end
  end

  def self.down
  end
end