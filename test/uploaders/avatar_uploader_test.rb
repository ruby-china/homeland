# frozen_string_literal: true

require "test_helper"

class AvatarUploaderTest < ActiveSupport::TestCase
  test "extension limit" do
    not_an_image = fixture_file_upload("test.html", "text/html")
    image = fixture_file_upload("test.png", "image/png")

    user = build(:user, avatar: not_an_image)
    assert_equal false, user.valid?
    assert_equal ["Avatar Invalid file format, only image allowed [jpg, jpeg, gif, png]"], user.errors.full_messages_for(:avatar)

    user = build(:user, avatar: image)
    assert_equal true, user.valid?
  end
end
