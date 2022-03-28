class Counter < ApplicationRecord
  belongs_to :countable, polymorphic: true
  validates :countable, presence: true

  delegate :to_i, :to_s, :inspect, to: :value

  def incr(by = 1)
    increment!(:value, by).value
  end

  def decr(by = 1)
    decrement!(:value, by).value
  end

  def respond_to_missing?
    true
  end

  def method_missing(method, *args, &block)
    if value.respond_to?(method)
      value.send(method, *args, &block)
    else
      super
    end
  end

  # Get top [limit] active users
  def self.active_users(limit: 32)
    counter_scope = where(countable_type: "User")
    counter_scope = counter_scope.where(key: :monthly_replies_count)
    counter_scope.includes(:countable).order("value desc").limit(limit).map(&:countable)
  end
end
