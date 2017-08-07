class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Redis::Objects

  scope :recent, -> { order(id: :desc) }
  scope :exclude_ids, ->(ids) { where.not(id: ids.map(&:to_i)) }
  scope :by_week, -> { where("created_at > ?", 7.days.ago.utc) }

  delegate :url_helpers, to: "Rails.application.routes"
end
