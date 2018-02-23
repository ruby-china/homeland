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
        expect(response.status).to eq 401
      end
    end

    context "with login" do
      it "should work" do
        login_user!
        post "/api/v3/photos.json", file: fixture_file_upload("test.png")
        @photo = Photo.last
        expect(response.status).to eq 200
        expect(@photo.user_id).to eq current_user.id
        expect(json["image_url"]).not_to eq nil
        expect(json["image_url"]).not_to eq ""
      end
    end
  end
end
