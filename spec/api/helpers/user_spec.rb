require 'spec_helper'

describe RubyChina::APIHelpers do
  before { extend RubyChina::APIHelpers }

  it "should get current_user by private token" do
    u = Factory(:user)
    u.update_private_token
    stub_params(:token => u.private_token)
    current_user.should == u
  end

  it "should return current_user as nil if private token is not currect" do
    stub_params(:token => "this-is-not-even-closer")
    current_user.should be_nil
  end

  private
  def stub_params(p = {})
    self.stub!(:params).and_return(p)
  end
end
