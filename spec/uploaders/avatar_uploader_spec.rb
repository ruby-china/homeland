# frozen_string_literal: true

require "rails_helper"

describe "AvatarUploader" do
  let(:not_an_image) { fixture_file_upload('test.html', 'text/html') }
  let(:svg_image) { fixture_file_upload('test.html', 'text/html') }
  let(:image) { fixture_file_upload('test.png', 'image/png') }

  it "extension limit" do
    user = build(:user, avatar: not_an_image)
    expect(user.valid?).to eq(false)
    expect(user.errors.full_messages_for(:avatar)).to eq(["头像仅允许图片文件上传 [jpg, jpeg, gif, png]"])

    user = build(:user, avatar: svg_image)
    expect(user.valid?).to eq(false)
    expect(user.errors.full_messages_for(:avatar)).to eq(["头像仅允许图片文件上传 [jpg, jpeg, gif, png]"])

    user = build(:user, avatar: image)
    expect(user.valid?).to eq(true)
  end
end