# frozen_string_literal: true

require "test_helper"

class Homeland::UtilsTest < ActiveSupport::TestCase
  test "omniauth_name" do
    assert_equal "GitHub", Homeland::Utils.omniauth_name(:github)
    assert_equal "Twitter", Homeland::Utils.omniauth_name(:twitter)
    assert_equal "微信", Homeland::Utils.omniauth_name(:wechat)
  end
end
