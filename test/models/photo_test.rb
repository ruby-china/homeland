# frozen_string_literal: true

require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = create(:user)
    @file = fixture_file_upload("test.png")
  end

  test "upload and delete" do
    photo = Photo.new(image: @file, user: @user)
    photo.save!
    assert_match Regexp.new("/uploads/photo/#{@user.login}/[a-zA-Z0-9\\-]+.png"), photo.image.url
    image_file_path = Rails.root.join("public/uploads/photo/#{photo[:image]}")
    assert File.exist?(image_file_path), "#{image_file_path} not exist"

    perform_enqueued_jobs do
      photo.destroy
    end
    refute File.exist?(image_file_path), "#{image_file_path} still exist"
  end
end
