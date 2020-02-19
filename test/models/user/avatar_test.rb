# frozen_string_literal: true

require "test_helper"

class User::AvatarTest < ActiveSupport::TestCase
  test "letter_avatar_char" do
    u = User.new(login: "hello")
    assert_equal "h", u.letter_avatar_char
    u = User.new(login: "apple")
    assert_equal "a", u.letter_avatar_char
    u = User.new(login: "Apple")
    assert_equal "a", u.letter_avatar_char
    u = User.new(login: "100px")
    assert_equal "1", u.letter_avatar_char
    u = User.new(login: "_100px")
    assert_equal "1", u.letter_avatar_char
    u = User.new(login: "-100px")
    assert_equal "1", u.letter_avatar_char
    u = User.new(login: "__hello")
    assert_equal "h", u.letter_avatar_char
  end

  test ".letter_avatar_url" do
    user = build(:user)
    assert_includes user.letter_avatar_url(240), "#{Setting.base_url}/system/letter_avatars/#{user.letter_avatar_char}"
  end

  test ".avatar?" do
    # should return false when avatar is nil
    u = User.new
    u[:avatar] = nil
    assert_equal false, u.avatar?

    # should return true when avatar is not nil
    u = User.new
    u[:avatar] = "1234"
    assert_equal true, u.avatar?
  end

  test ".large_avatar_url" do
    user = build(:user, login: "hello")

    user.avatar = nil
    assert_includes user.large_avatar_url, "/system/letter_avatars/h.png"

    # avatar is present
    user[:avatar] = "aaa.jpg"
    assert_equal user.avatar.url(:lg), user.large_avatar_url
  end
end
