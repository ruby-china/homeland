class RemoveOldTopicFollowers < Mongoid::Migration
  def self.up
    Topic.unscoped.all.each do |topic|
      topic.unset(:follower_ids)
    end
  end
end