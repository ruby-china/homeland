class RegenerateUserAvatars < Mongoid::Migration
  def self.up
    User.all.each do |u|
      next if u.avatar.blank?
      begin
        u.avatar.recreate_versions!
        u.save
      rescue RestClient::ResourceNotFound
        next
      end
    end
  end

  def self.down
  end
end