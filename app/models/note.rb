# 记事本
class Note < ActiveRecord::Base
  include Redis::Objects

  belongs_to :user

  counter :hits, default: 0

  scope :recent_updated, -> { desc(:updated_at) }
  scope :published, -> { where(publish: true) }

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
    inc(changes_count: 1)
  end

  def display_title
    (title || "").gsub(/^[\#]+/, '')
  end
end
