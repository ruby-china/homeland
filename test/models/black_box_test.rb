# frozen_string_literal: true

require "test_helper"

class BlackBoxTest < ActiveSupport::TestCase
  setup do
    @trust_user = create(:vip)
    @blocked_user = create(:user, state: :blocked)
    @deleted_user = create(:user, state: :deleted)
    @user_today = create(:user, created_at: Time.now)
    @user_over_three_day = create(:user, created_at: 4.days.ago)
    @user_over_a_week = create(:user, created_at: 8.days.ago)
  end

  test "calculate_spaminess" do
    [Topic, Comment].each do |klass|
      target = klass.new(user: @trust_user)
      assert_equal 0, BlackBox.calculate_spaminess(target)

      target = klass.new(user: @blocked_user)
      assert_equal 100, BlackBox.calculate_spaminess(target)

      target = klass.new(user: @deleted_user)
      assert_equal 100, BlackBox.calculate_spaminess(target)

      target = klass.new(user: nil)
      assert_equal 100, BlackBox.calculate_spaminess(target)

      target = klass.new(user: @user_over_a_week)
      assert_equal 0, BlackBox.calculate_spaminess(target)

      target = klass.new(user: @user_over_three_day)
      assert_equal 25, BlackBox.calculate_spaminess(target)

      target = klass.new(user: @user_today)
      assert_equal 50, BlackBox.calculate_spaminess(target)
    end
  end

  test "calculate_bonus_score" do
    assert_equal 0, BlackBox.calculate_bonus_score(nil)
    assert_equal 0, BlackBox.calculate_bonus_score("")
    assert_equal 2, BlackBox.calculate_bonus_score("1" * 201)
    assert_equal 3, BlackBox.calculate_bonus_score("```" * 201)
  end
end
