require 'rails_helper'

describe RubyChina::APIHelpers, :type => :request do
  before { extend RubyChina::APIHelpers }

  it "should get current_user by private token" do
    u = Factory(:user)
    u.update_private_token
    stub_params(:token => u.private_token)
    expect(current_user).to eq(u)
  end

  it "should return current_user as nil if private token is not currect" do
    stub_params(:token => "this-is-not-even-closer")
    expect(current_user).to be_nil
  end

  private
  def stub_params(p = {})
    allow(self).to receive(:params).and_return(p)
  end
end
