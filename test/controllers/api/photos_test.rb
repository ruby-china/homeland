# frozen_string_literal: true

require "spec_helper"
require "active_support/core_ext"

describe Api::V3::PhotosController do
  let(:json) { JSON.parse(response.body) }

  describe "POST /api/v3/photos.json" do
    include ActionDispatch::TestProcess

    it "without login should response 401" do
      post "/api/v3/photos.json"
      assert_equal 401, response.status
    end

    it "with login should work" do
      login_user!
      post "/api/v3/photos.json", file: fixture_file_upload("test.png", "image/png")
      @photo = Photo.last
      assert_equal 200, response.status
      assert_equal current_user.id, @photo.user_id
      assert_equal true, json["image_url"].present?
    end
  end
end
