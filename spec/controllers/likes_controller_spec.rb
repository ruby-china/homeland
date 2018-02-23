# frozen_string_literal: true

require "rails_helper"

describe LikesController, type: :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:topic) { create(:topic) }

  it "GET /likes" do
    get :index, params: { type: "Topic", id: topic.id }
    expect(response).to have_http_status(200)
  end

  it "POST /likes" do
    sign_in user
    post :create, params: { type: "Topic", id: topic.id }
    expect(response.body).to eq("1")
    expect(topic.reload.likes_count).to eq(1)

    post :create, params: { type: "Topic", id: topic.id }
    expect(response.body).to eq("1")
    expect(topic.reload.likes_count).to eq(1)
    sign_out user

    sign_in user2
    post :create, params: { type: "Topic", id: topic.id }
    expect(response.body).to eq("2")
    expect(topic.reload.likes_count).to eq(2)
    sign_out user2

    sign_in user
    delete :destroy, params: { type: "Topic", id: topic.id }
    expect(response.body).to eq("1")
    expect(topic.reload.likes_count).to eq(1)
    sign_out user

    sign_in user2
    delete :destroy, params: { type: "Topic", id: topic.id }
    expect(response.body).to eq("0")
    expect(topic.reload.likes_count).to eq(0)
  end

  it "require login" do
    post :create
    expect(response.status).to eq(302)

    delete :destroy, params: { id: 1, type: "a" }
    expect(response.status).to eq(302)
  end

  it "result -1, -2 when params is wrong" do
    sign_in user
    post :create, params: { type: "Ask", id: 1 }
    expect(response.body).to eq("-1")

    delete :destroy, params: { type: "Ask", id: 1 }
    expect(response.body).to eq("-1")

    post :create, params: { type: "Topic", id: -1 }
    expect(response.body).to eq("-2")

    delete :destroy, params: { type: "Topic", id: -1 }
    expect(response.body).to eq("-2")
  end
end
