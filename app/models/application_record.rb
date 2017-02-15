class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Redis::Objects

  scope :recent, -> { order(id: :desc) }
  scope :exclude_ids, ->(ids) { where.not(id: ids.map(&:to_i)) }
  scope :by_week, -> { where('created_at > ?', 7.days.ago.utc) }

  delegate :url_helpers, to: 'Rails.application.routes'

  # FIXME: 需要原子化操作
  def push(hash)
    hash.each_key do |key|
      self.send("#{key}_will_change!")
      old_val = self[key] || []
      old_val << hash[key].to_i
      old_val.uniq!
      update(key => old_val)
    end
  end

  # FIXME: 需要原子化操作
  def pull(hash)
    hash.each_key do |key|
      self.send("#{key}_will_change!")
      old_val = self[key]
      return true if old_val.blank?
      old_val.delete(hash[key].to_i)
      update(key => old_val)
    end
  end
end
