# coding: utf-8  
# 记事本
class Note < ActiveRecord::Base
  attr_protected :user_id, :changes_count, :word_count
  belongs_to :user, :counter_cache => true

  default_scope :order => "id desc"

  before_save :auto_set_value
  def auto_set_value
    if !self.body.blank?
      self.title = self.body.split("\n").first[0..50]
      self.word_count = self.body.length
    end
  end

  before_update :update_changes_count
  def update_changes_count
    self.changes_cout += 1
  end
end
