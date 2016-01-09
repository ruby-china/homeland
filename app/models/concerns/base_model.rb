module BaseModel
  extend ActiveSupport::Concern

  included do
    scope :recent, -> { order(id: :desc) }
    scope :exclude_ids, ->(ids) { where(:id.nin => ids.map(&:to_i)) }
    scope :by_week, -> { where("created_at > ?", 7.days.ago.utc) }

    delegate :url_helpers, to: 'Rails.application.routes'
  end
end
