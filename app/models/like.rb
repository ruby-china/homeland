# coding: utf-8
# 喜欢
# 多态设计，可以用于收藏 Topic, Page, Post ...
class Like
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::BaseModel

  belongs_to :likeable, :polymorphic => true
  belongs_to :user

  index :user_id
  index [[:user_id, Mongo::ASCENDING],[:likeable_type, Mongo::ASCENDING], [:likeable_id, Mongo::ASCENDING]]

  scope :topics, where(:likeable_type => 'Topic')

  after_create :increase_counter_cache
  def increase_counter_cache
    return if self.likeable.blank? or self.user.blank?
    self.likeable.inc(:likes_count,1)
    self.user.inc(:likes_count, 1)
  end

  after_destroy :decrease_counter_cache
  def decrease_counter_cache
    return if self.likeable.blank? or self.user.blank?
    self.likeable.inc(:likes_count,-1)
    self.user.inc(:likes_count, -1)
  end
end
