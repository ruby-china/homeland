class MoveLikesDataToTopicLikedUserIdsField < Mongoid::Migration
  def self.up
    Topic.where(:likes_count.gt => 0).each do |topic|
      topic.set(:liked_user_ids, Like.where(:likeable_type => "Topic", :likeable_id => topic.id).collect { |like| like.user_id })
      print "."
    end
    Like.collection.drop
  end
end