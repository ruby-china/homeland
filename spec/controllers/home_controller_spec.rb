#encoding: utf-8
require "spec_helper"

describe HomeController do
  describe ":index" do
    let(:user) { Factory :user }
    it "should show register link if user not signed in" do
      get :index
      response.should be_success
      visit '/'
      get :index
      page.should have_content('注册')
    end

    it "should have hot topic lists if user is signed in" do
      visit '/'
      sign_in user

      get :index
      page.should have_content('社区精华贴')
    end
  end
end