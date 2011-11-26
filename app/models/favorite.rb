# coding: utf-8
# 收藏表
# 多态设计，可以用于收藏 Topic, Page, Post ...
class Favorite
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::BaseModel
  
  belongs_to :favoriteable, :polymorphic => true
  belongs_to :user
  
  index :user_id
  index [:user_id,:favoriteable_type, :favoriteable_id]
  
  after_create :increase_counter_cache
  def increase_counter_cache
    return if self.favoriteable.blank?
    self.favoriteable.inc(:favorites_count,1)
  end

  before_destroy :decrease_counter_cache
  def decrease_counter_cache
    return if self.favoriteable.blank?
    self.favoriteable.inc(:favorites_count,-1)
  end
  
end