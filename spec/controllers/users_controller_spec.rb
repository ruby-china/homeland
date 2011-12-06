require 'spec_helper'

describe UsersController do
  describe "#show, #replies, #likes" do
    it "should render 404 if user is nil" do
      get :show, :id => 1
      response.status.should == 404
      
      get :replies, :id => 1
      response.status.should == 404
      
      get :likes, :id => 1
      response.status.should == 404
    end
  end
end
