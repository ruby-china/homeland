# frozen_string_literal: true

require "test_helper"

class User::OnlineTrackableTest < ActiveSupport::TestCase
  test "online query methods should work" do
    Redis.current.del(User::REDIS_ONLINE_KEY)
    user = create(:user)
    assert_equal false, user.online?
    assert_nil user.last_online_at
    assert_equal 0, User.online_users_count
  end

  test "touch_last_online_ts method should work" do
    Redis.current.del(User::REDIS_ONLINE_KEY)
    user = create(:user)
    assert_equal false, user.online?
    user.touch_last_online_ts
    assert_equal true, user.online?
    assert_equal Time, user.last_online_at.class
    assert_equal 1, User.online_users_count
  end

  test "cleanup_inactive_online_stats method should work" do
    Redis.current.del(User::REDIS_ONLINE_KEY)
    user_1 = create(:user)
    user_2 = create(:user)
    user_1.touch_last_online_ts
    user_2.touch_last_online_ts
    assert_equal 2, User.online_users_count

    User.cleanup_inactive_online_stats(past_datetime: Time.current)
    assert_equal 0, User.online_users_count
  end
end
