# 开启关闭帖子功能
module Closeable
  extend ActiveSupport::Concern

  included do
  end

  def closed?
    closed_at.present?
  end

  def close!
    transaction do
      Reply.create_system_event(action: "close", topic_id: self.id)
      update!(closed_at: Time.now)
    end
  end

  def open!
    transaction do
      update!(closed_at: nil)
      Reply.create_system_event(action: "reopen", topic_id: self.id)
    end
  end
end
