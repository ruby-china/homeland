# frozen_string_literal: true

require "rails_helper"

describe SessionsController, type: :controller do
  describe ":new" do
    before { request.env["devise.mapping"] = Devise.mappings[:user] }
    it "should render new template" do
      get :new
      assert_equal 200, response.status
    end

    it "should redirect to sso login" do
      allow(Setting).to receive(:sso_enabled?).and_return(true)
      get :new
      assert_equal 302, response.status
      assert_includes response.location, "/auth/sso"
    end

    context "cache referrer" do
      it "should store referrer if it's from self site" do
        session["return_to"] = "/account/edit?id=123"
        old_return_to = session["return_to"]
        get :new
        assert_equal old_return_to, session["return_to"]
      end
    end
  end

  describe ":create" do
    let (:user) { create(:user) }
    before { request.env["devise.mapping"] = Devise.mappings[:user] }
    it "should redirect to home" do
      post :create, params: { user: { login: user.login, password: user.password } }
      assert_redirected_to root_path
    end

    it "should render json" do
      post :create, params: { format: :json, user: { login: user.login, password: user.password } }
      assert_equal 201, response.status
      assert_equal user.login, response.parsed_body["login"]
      assert_equal user.email, response.parsed_body["email"]
    end
  end
end
