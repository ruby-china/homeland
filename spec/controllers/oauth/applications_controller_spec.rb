# frozen_string_literal: true

require "rails_helper"

describe Oauth::ApplicationsController, type: :controller do
  let(:application) { create(:application, owner: user) }
  describe ":index" do
    let(:user) { create :user }
    it "should show register link if user not signed in" do
      get :index
      expect(response).not_to have_http_status(200)
    end

    it "should have hot topic lists if user is signed in" do
      sign_in user
      get :index
      expect(response).to have_http_status(200)
      expect(response.body).to match(/管理的应用列表/)
    end

    it "should :new" do
      sign_in user
      get :new
      expect(response).to have_http_status(200)
      expect(response.body).to match(/注册新应用/)
    end

    it "should :edit" do
      sign_in user
      get :edit, params: { id: application.id }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/修改应用信息/)
    end
  end
end
