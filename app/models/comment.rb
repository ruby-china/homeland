# coding: utf-8
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::SoftDelete

  field :body

  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  index :user_id
  index :commentable_type
  index :commentable_id

  validates_presence_of :body

  before_create :fix_commentable_id
  def fix_commentable_id
    self.commentable_id = self.commentable_id.to_i
  end

  after_create :increase_counter_cache
  def increase_counter_cache
    return if self.commentable.blank?
    self.commentable.inc(:comments_count,1)
  end

  before_destroy :decrease_counter_cache
  def decrease_counter_cache
    return if self.commentable.blank?
    self.commentable.inc(:comments_count,-1)
  end

end
