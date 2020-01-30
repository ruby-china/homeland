# frozen_string_literal: true

require "rails_helper"

describe Oauth::ApplicationsController, type: :controller do
  let(:application) { create(:application, owner: user) }
  describe ":index" do
    let(:user) { create :user }
    it "should show register link if user not signed in" do
      get :index
      refute_equal 200, response.status
    end

    it "should have hot topic lists if user is signed in" do
      sign_in user
      get :index
      assert_equal 200, response.status
      assert_match /管理的应用列表/, response.body
    end

    it "should :new" do
      sign_in user
      get :new
      assert_equal 200, response.status
      assert_match /注册新应用/, response.body
    end

    it "should :edit" do
      sign_in user
      get :edit, params: { id: application.id }
      assert_equal 200, response.status
      assert_match /修改应用信息/, response.body
    end
  end
end
