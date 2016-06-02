# 开启关闭帖子功能
module Closeable
  extend ActiveSupport::Concern

  included do
  end

  def closed?
    closed_at.present?
  end

  def close!
    self.closed_at = Time.now
    self.transaction do
      Reply.create_system_event(action: 'close', topic_id: self.id)
      self.save
    end
  end

  def open!
    self.closed_at = nil
    self.transaction do
      Reply.create_system_event(action: 'reopen', topic_id: self.id)
      self.save
    end
  end
end
