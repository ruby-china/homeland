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
end
