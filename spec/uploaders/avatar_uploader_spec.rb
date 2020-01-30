# frozen_string_literal: true

require "rails_helper"

describe "AvatarUploader" do
  let(:not_an_image) { fixture_file_upload("test.html", "text/html") }
  let(:svg_image) { fixture_file_upload("test.html", "text/html") }
  let(:image) { fixture_file_upload("test.png", "image/png") }

  it "extension limit" do
    user = build(:user, avatar: not_an_image)
    assert_equal false, user.valid?
    assert_equal ["头像仅允许图片文件上传 [jpg, jpeg, gif, png]"], user.errors.full_messages_for(:avatar)

    user = build(:user, avatar: svg_image)
    assert_equal false, user.valid?
    assert_equal ["头像仅允许图片文件上传 [jpg, jpeg, gif, png]"], user.errors.full_messages_for(:avatar)

    user = build(:user, avatar: image)
    assert_equal true, user.valid?
  end
end
