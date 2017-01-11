# 记事本
class Note < ApplicationRecord
  second_level_cache

  belongs_to :user

  counter :hits, default: 0

  scope :recent_updated, -> { order(updated_at: :desc) }
  scope :published,      -> { where(publish: true) }

  validates :body, presence: true

  before_save :auto_set_value
  def auto_set_value
    unless body.blank?
      self.title = body.split("\n").first[0..50]
      self.word_count = body.length
    end
  end

  before_update :update_changes_count
  def update_changes_count
    self.changes_count = 0 if changes_count.blank?
    increment(:changes_count)
  end

  def display_title
    (title || '').gsub(/^[\#]+/, '')
  end
end
