# frozen_string_literal: true

require "test_helper"

class CounterTest < ActiveSupport::TestCase
  test "base" do
    counter = create :counter
    assert_equal 0, counter.value
    assert_equal 0, counter.to_i

    counter.incr
    assert_equal 1, counter.value

    counter.incr
    assert_equal 2, counter.value

    counter.incr(3)
    assert_equal 5, counter.value

    counter.decr
    assert_equal 4, counter.value

    counter.decr(2)
    assert_equal 2, counter.value
  end

  test "User counter" do
    user = create(:user)

    assert_equal 0, user.yearly_replies_count.to_i
    user.yearly_replies_count.incr
    assert_equal 1, user.yearly_replies_count.to_i
    user.yearly_replies_count.decr
    assert_equal 0, user.yearly_replies_count.to_i

    assert_equal 0, user.monthly_replies_count.to_i
    user.monthly_replies_count.incr
    assert_equal 1, user.monthly_replies_count.to_i
    user.monthly_replies_count.decr
    assert_equal 0, user.monthly_replies_count.to_i
  end
end
