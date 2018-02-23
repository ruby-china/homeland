# frozen_string_literal: true

require "rails_helper"

describe NodesController, type: :controller do
  let(:node) { create(:node) }
  let(:user) { create(:user) }

  it "should have an index action" do
    get :index
    expect(response).to have_http_status(200)
  end

  it "should have an block action" do
    sign_in user
    post :block, params: { id: node }
    expect(response).to have_http_status(200)
  end

  it "should have an unblock action" do
    sign_in user
    post :unblock, params: { id: node }
    expect(response).to have_http_status(200)
  end
end
