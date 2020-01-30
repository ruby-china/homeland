# frozen_string_literal: true

require "rails_helper"

describe NodesController, type: :controller do
  let(:node) { create(:node) }
  let(:user) { create(:user) }

  it "should have an index action" do
    get :index
    assert_equal 200, response.status
  end

  it "should have an block action" do
    sign_in user
    post :block, params: { id: node }
    assert_equal 200, response.status
  end

  it "should have an unblock action" do
    sign_in user
    post :unblock, params: { id: node }
    assert_equal 200, response.status
  end
end
