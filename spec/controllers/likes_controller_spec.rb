# frozen_string_literal: true

require "rails_helper"

describe LikesController, type: :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:topic) { create(:topic) }

  it "GET /likes" do
    get :index, params: { type: "Topic", id: topic.id }
    assert_equal 200, response.status
  end

  it "POST /likes" do
    sign_in user
    post :create, params: { type: "Topic", id: topic.id }
    assert_equal "1", response.body
    assert_equal 1, topic.reload.likes_count

    post :create, params: { type: "Topic", id: topic.id }
    assert_equal "1", response.body
    assert_equal 1, topic.reload.likes_count
    sign_out user

    sign_in user2
    post :create, params: { type: "Topic", id: topic.id }
    assert_equal "2", response.body
    assert_equal 2, topic.reload.likes_count
    sign_out user2

    sign_in user
    delete :destroy, params: { type: "Topic", id: topic.id }
    assert_equal "1", response.body
    assert_equal 1, topic.reload.likes_count
    sign_out user

    sign_in user2
    delete :destroy, params: { type: "Topic", id: topic.id }
    assert_equal "0", response.body
    assert_equal 0, topic.reload.likes_count
  end

  it "require login" do
    post :create
    assert_equal 302, response.status

    delete :destroy, params: { id: 1, type: "a" }
    assert_equal 302, response.status
  end

  it "result -1, -2 when params is wrong" do
    sign_in user
    post :create, params: { type: "Ask", id: 1 }
    assert_equal "-1", response.body

    delete :destroy, params: { type: "Ask", id: 1 }
    assert_equal "-1", response.body

    post :create, params: { type: "Topic", id: -1 }
    assert_equal "-2", response.body

    delete :destroy, params: { type: "Topic", id: -1 }
    assert_equal "-2", response.body
  end
end
