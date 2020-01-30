# frozen_string_literal: true

require "test_helper"

class PhotoUploaderTest < ActiveSupport::TestCase
  test "extension limit" do
    not_an_image = fixture_file_upload("test.html", "text/html")
    svg_image = fixture_file_upload("test.html", "text/html")
    image = fixture_file_upload("test.png", "image/png")

    photo = build(:photo, image: not_an_image)
    assert_equal false, photo.valid?
    assert_equal ["Image仅允许图片文件上传 [jpg, jpeg, gif, png]"], photo.errors.full_messages_for(:image)

    photo = build(:photo, image: svg_image)
    assert_equal false, photo.valid?
    assert_equal ["Image仅允许图片文件上传 [jpg, jpeg, gif, png]"], photo.errors.full_messages_for(:image)

    photo = build(:photo, image: image)
    assert_equal true, photo.valid?
  end
end
