# frozen_string_literal: true

require "rails_helper"

describe SessionsController, type: :controller do
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

    context "cache referrer" do
      it "should store referrer if it's from self site" do
        session["return_to"] = "/account/edit?id=123"
        old_return_to = session["return_to"]
        get :new
        expect(session["return_to"]).to eq(old_return_to)
      end
    end
  end

  describe ":create" do
    let (:user) { create(:user) }
    before { request.env["devise.mapping"] = Devise.mappings[:user] }
    it "should redirect to home" do
      post :create, params: { user: { login: user.login, password: user.password } }
      expect(response).to redirect_to(root_path)
    end

    it "should render json" do
      post :create, params: { format: :json, user: { login: user.login, password: user.password } }
      expect(response.status).to eq(201)
      json = JSON.parse(response.body).symbolize_keys
      expect(json).to match(login: user.login, email: user.email)
    end
  end
end
