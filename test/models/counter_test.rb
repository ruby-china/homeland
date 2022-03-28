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

  test "Top active users from counter" do
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)
    user4 = create(:user)

    create(:counter, countable: user1, key: "monthly_replies_count", value: 10)
    create(:counter, countable: user2, key: "monthly_replies_count", value: 1)
    create(:counter, countable: user3, key: "monthly_replies_count", value: 30)
    create(:counter, countable: user4, key: "monthly_replies_count", value: 28)

    assert_equal [user3, user4, user1, user2], Counter.active_users
  end
end
