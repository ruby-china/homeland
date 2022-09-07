# frozen_string_literal: true

require "test_helper"

class User::OnlineTrackableTest < ActiveSupport::TestCase
  def setup
    Redis.current.del(User::REDIS_ONLINE_KEY)
  end

  test "online query methods should work" do
    assert_equal 0, User.count
    user = create(:user)
    assert_equal false, user.online?
    assert_nil user.last_online_at
  end

  test "touch_last_online_ts method should work" do
    user = create(:user)

    assert_difference "User.online_users_count", 1 do
      user.touch_last_online_ts
    end

    assert_equal true, user.online?
    assert_equal Time, user.last_online_at.class
  end

  test "cleanup_inactive_online_stats method should work" do
    user_1 = create(:user)
    user_2 = create(:user)
    user_1.touch_last_online_ts
    user_2.touch_last_online_ts
    online_count = User.online_users_count
    User.cleanup_inactive_online_stats(past_datetime: Time.current)
    assert_not_equal online_count, User.online_users_count
  end
end
