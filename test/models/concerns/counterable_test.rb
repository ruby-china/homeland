# frozen_string_literal: true

require "test_helper"

class CounterableTest < ActiveSupport::TestCase
  test "Topic hits" do
    Redis.current.del("topic:123:hits")
    t = Topic.new(id: 123)

    # Ensure Redis DB is 0
    assert_equal 0, t.hits.redis._client.db
    assert_equal false, t.hits.nil?
    assert_equal 0, t.hits.to_i
    assert_equal "topic:123:hits", t.hits.key
    t.hits.incr(1)
    assert_equal 1, t.hits.to_i
    t.hits.incr(2)
    assert_equal 3, t.hits.to_i
    assert_equal "3", t.hits.to_s
  end
end
