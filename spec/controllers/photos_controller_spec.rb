require "spec_helper"

describe PhotosController do
  let(:user) { Factory :user }
  describe ":tiny_new" do
    context "unauthenticated" do
      it "should not allow anonymous access" do
        get :tiny_new
        response.should_not be_success
      end
    end

    context "authenticated" do
      it "should allow access from authenticated user" do
        sign_in user
        get :tiny_new
        response.should be_success
      end
    end
  end
end