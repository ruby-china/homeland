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
    self.save
  end

  def open!
    self.closed_at = Time.now
    self.save
  end
end
