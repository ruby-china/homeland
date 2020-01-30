# frozen_string_literal: true

require "rails_helper"
require "active_support/core_ext"

describe "API", type: :request do
  let(:json) { JSON.parse(response.body) }

  describe "POST /api/v3/photos.json" do
    include ActionDispatch::TestProcess

    context "without login" do
      it "should response 401" do
        post "/api/v3/photos.json"
        assert_equal 401, response.status
      end
    end

    context "with login" do
      it "should work" do
        login_user!
        post "/api/v3/photos.json", file: fixture_file_upload("test.png")
        @photo = Photo.last
        assert_equal 200, response.status
        assert_equal current_user.id, @photo.user_id
        assert_equal true, json["image_url"].present?
      end
    end
  end
end
