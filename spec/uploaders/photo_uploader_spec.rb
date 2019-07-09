# frozen_string_literal: true

require "rails_helper"

describe "PhotoUploader" do
  let(:not_an_image) { fixture_file_upload('test.html', 'text/html') }
  let(:image) { fixture_file_upload('test.png', 'image/png') }

  it "extension limit" do
    photo = build(:photo, image: not_an_image)
    expect(photo.valid?).to eq(false)
    expect(photo.errors.full_messages_for(:image)).to eq(["Image不能为空字符", "Image仅允许图片文件上传 [jpg, jpeg, gif, png, svg]"])

    photo = build(:photo, image: image)
    expect(photo.valid?).to eq(true)
  end
end