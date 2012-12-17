class MoveTopicRepliedAtSortToLastActiveMark < Mongoid::Migration
  def self.up
    Topic.all.each do |t|
      t.update_attribute(:last_active_mark, t.replied_at.to_i)
    end
  end

  def self.down
  end
end