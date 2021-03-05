# frozen_string_literal: true

class Comment < ApplicationRecord
  include UserAvatarDelegate
  include Mentionable
  include MarkdownBody

  belongs_to :commentable, polymorphic: true
  belongs_to :user, optional: true

  validates :body, presence: true

  attr_writer :mentioned_user_ids

  def mentioned_user_ids
    @mentioned_user_ids ||= []
  end

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

  after_commit :notify_comment_created, on: [:create]
  def notify_comment_created
    return if commentable.blank?
    receiver_id = commentable&.user_id
    return if receiver_id.blank?
    notified_user_ids = mentioned_user_ids || []
    return if notified_user_ids.include?(receiver_id)

    Notification.create(
      notify_type: "comment",
      target: self,
      second_target: commentable,
      actor_id: user_id,
      user_id: receiver_id
    )
  end
end
