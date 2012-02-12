require "spec_helper"

describe HomeController do
  describe ":index" do
    let(:user) { Factory :user }
    it "should show index page if user not signed in" do
      get :index
      response.should be_success
    end

    it "should redirect to topics_path if user is signed in" do
      sign_in user
      get :index
      response.should redirect_to(topics_path)
    end
  end
end