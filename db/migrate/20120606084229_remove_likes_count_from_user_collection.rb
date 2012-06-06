class RemoveLikesCountFromUserCollection < Mongoid::Migration
  def self.up
    User.where(:likes_count.gt => 0).each do |user|
      user.unset(:likes_count)
      print "."
    end
  end
end