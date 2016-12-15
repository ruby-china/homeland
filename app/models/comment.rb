class Comment < ApplicationRecord
  include MarkdownBody
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :body, presence: true

  before_create :fix_commentable_id
  def fix_commentable_id
    self.commentable_id = commentable_id.to_i
  end

  after_create :increase_counter_cache
  def increase_counter_cache
    return if commentable.blank?
    commentable.increment!(:comments_count)
  end

  before_destroy :decrease_counter_cache
  def decrease_counter_cache
    return if commentable.blank?
    commentable.decrement!(:comments_count)
  end
end
