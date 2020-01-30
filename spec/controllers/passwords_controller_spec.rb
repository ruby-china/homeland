# frozen_string_literal: true

require "rails_helper"

describe PasswordsController, type: :controller do
  describe ":new" do
    before { request.env["devise.mapping"] = Devise.mappings[:user] }

    it "should render new tempalte" do
      get :new
      assert_equal 200, response.status
    end

    it "should redirect to sso login" do
      allow(Setting).to receive(:sso_enabled?).and_return(true)
      get :new
      assert_equal 302, response.status
      assert_includes response.location, "/auth/sso"
    end
  end

  describe ":create" do
    let(:user) { create(:user) }
    before { request.env["devise.mapping"] = Devise.mappings[:user] }

    it "should work" do
      post :create, params: { user: { email: user.email } }
      assert_equal 200, response.status
    end
    it "should redirect to sign in path after success" do
      allow_any_instance_of(ActionController::Base).to receive(:verify_complex_captcha?).and_return(true)
      post :create, params: { user: { email: user.email } }
      assert_redirected_to "/account/sign_in"
    end
  end
end
