# frozen_string_literal: true

require "test_helper"

class PhotoUploaderTest < ActiveSupport::TestCase
  setup do
    @uploader = PhotoUploader.new
  end

  test "allow_thumb?" do
    assert_equal false, @uploader.allow_thumb?("https://google.com/foo.zip")
    assert_equal false, @uploader.allow_thumb?("https://google.com/foo")
    assert_equal true, @uploader.allow_thumb?("https://google.com/foo.jpg")
    assert_equal true, @uploader.allow_thumb?("https://google.com/foo.jpeg")
    assert_equal true, @uploader.allow_thumb?("https://google.com/foo.gif")
    assert_equal true, @uploader.allow_thumb?("https://google.com/foo.png")
  end

  test "extension limit" do
    not_an_image = fixture_file_upload("test.html", "text/html")
    svg_image = fixture_file_upload("test.svg", "image/svg+xml")
    image = fixture_file_upload("test.png", "image/png")

    photo = build(:photo, image: not_an_image)
    assert_equal false, photo.valid?
    assert_equal ["Image Invalid file format, only image allowed [jpg, jpeg, gif, png]"], photo.errors.full_messages_for(:image)

    photo = build(:photo, image: svg_image)
    assert_equal false, photo.valid?

    photo = build(:photo, image: image)
    assert_equal true, photo.valid?
  end
end
