# frozen_string_literal: true

require "test_helper"

class User::AvatarTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

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
    u = User.new(login: "_@")
    assert_equal "-", u.letter_avatar_char
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
  end

  test "non-image upload" do
    file = fixture_file_upload("test.png", "text/html")
    user = create(:user)
    user.avatar = file
    user.save
    assert_equal "You are not allowed to upload text/html files, allowed types: image/*", user.errors.messages[:avatar]&.first
  end

  test "upload and soft_delete" do
    file = fixture_file_upload("test.png")
    user = create(:user)
    user.avatar = file
    user.save!
    assert_match Regexp.new("/uploads/user/avatar/#{user.id}/[a-zA-Z0-9\\-]+.png"), user.avatar.url
    image_file_path = Rails.root.join("public/uploads/user/#{user[:avatar]}")
    assert File.exist?(image_file_path), "#{image_file_path} not exist"

    perform_enqueued_jobs do
      user.soft_delete
    end
    user.reload
    assert_nil user[:avatar]
    refute File.exist?(image_file_path), "#{image_file_path} still exist"
  end

  test "upload and destroy" do
    file = fixture_file_upload("test.png")
    user = create(:user)
    user.avatar = file
    user.save!
    assert_match Regexp.new("/uploads/user/avatar/#{user.id}/[a-zA-Z0-9\\-]+.png"), user.avatar.url
    image_file_path = Rails.root.join("public/uploads/user/#{user[:avatar]}")
    assert File.exist?(image_file_path), "#{image_file_path} not exist"

    perform_enqueued_jobs do
      user.destroy
    end
    refute File.exist?(image_file_path), "#{image_file_path} still exist"
  end
end
