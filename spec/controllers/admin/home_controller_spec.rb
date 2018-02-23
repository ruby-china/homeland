# frozen_string_literal: true

require "rails_helper"

describe Admin::HomeController, type: :controller do
  let(:user) { create :user }
  let(:admin) { create :admin }
  describe "Admin requirement" do
    it "should open with admin user" do
      sign_in admin
      get :index
      expect(response.status).to eq 200
    end

    it "should 404 with non admin user" do
      sign_in user
      get :index
      expect(response.status).to eq 404
    end
  end
end
