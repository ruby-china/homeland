# encoding: utf-8

class PageView
  include Virtus.model

  attribute :target_id, Integer
  attribute :timestamp, Integer, default: Time.now.to_i

  def repository
    @repository ||= Repository::PageView.instance
  end

  def valid?
    target_id.present?
  end

  def save
    repository.save(self)
  end

  class << self

    def create(*args)
      obj = new(*args)
      obj.valid? && obj.save
    end
  end
end
