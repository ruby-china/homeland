# frozen_string_literal: true

require "spec_helper"

describe Oauth::ApplicationsController do
  let(:application) { create(:application, owner: user) }

  describe "GET /oauth/applications" do
    let(:user) { create :user }

    it "should show register link if user not signed in" do
      get oauth_applications_path
      refute_equal 200, response.status
    end

    it "should have hot topic lists if user is signed in" do
      sign_in user
      get oauth_applications_path
      assert_equal 200, response.status
      assert_match(/Applications/, response.body)
    end

    it "should :new" do
      sign_in user
      get new_oauth_application_path
      assert_equal 200, response.status
      assert_match(/Create Application/, response.body)
    end

    it "should :edit" do
      sign_in user
      get edit_oauth_application_path(application)
      assert_equal 200, response.status
      assert_match(/Edit Application/, response.body)
    end
  end
end
