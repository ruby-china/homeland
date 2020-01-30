# frozen_string_literal: true

require "rails_helper"

describe "PhotoUploader" do
  let(:not_an_image) { fixture_file_upload("test.html", "text/html") }
  let(:svg_image) { fixture_file_upload("test.html", "text/html") }
  let(:image) { fixture_file_upload("test.png", "image/png") }

  it "extension limit" do
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
