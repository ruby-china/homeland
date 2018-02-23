# frozen_string_literal: true

require "rails_helper"

describe AccountController, type: :controller do
  describe ":new" do
    before { request.env["devise.mapping"] = Devise.mappings[:user] }

    it "should render new template" do
      get :new
      expect(response).to have_http_status(200)
    end

    it "should redirect to sso login" do
      allow(Setting).to receive(:sso_enabled?).and_return(true)
      get :new
      expect(response.status).to eq(302)
      expect(response.location).to include("/auth/sso")
    end
  end

  describe ":create" do
    let(:user) { create :user }
    before { request.env["devise.mapping"] = Devise.mappings[:user] }
    it "should work" do
      allow_any_instance_of(ActionController::Base).to receive(:verify_rucaptcha?).and_return(true)
      post :create, params: { format: :js, user: { login: "newlogin", email: "newlogin@email.com", password: "password" } }
      expect(response).to have_http_status(200)
    end
  end

  describe ":edit" do
    let(:user) { create :user }
    before { request.env["devise.mapping"] = Devise.mappings[:user] }
    it "should work" do
      sign_in user
      get :edit
      expect(response.status).to eq 302
      expect(response.location).to include("/setting")
    end
  end
end
