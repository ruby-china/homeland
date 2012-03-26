class MoveLikesToFavorites < Mongoid::Migration
  def self.up
    User.all.each do |u|
      ids = u.likes.collect { |like| like.likeable_id }
      if not ids.blank?
        u.update_attribute(:favorite_topic_ids, ids.uniq)
        print "."
      end
    end
  end

  def self.down
  end
end