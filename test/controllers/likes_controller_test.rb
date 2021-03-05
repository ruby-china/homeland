# frozen_string_literal: true

require "spec_helper"

describe LikesController do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:topic) { create(:topic) }

  it "GET /likes" do
    get likes_path, params: {type: "Topic", id: topic.id}
    assert_equal 200, response.status
  end

  it "POST /likes" do
    sign_in user
    post likes_path, params: {type: "Topic", id: topic.id}
    assert_equal "1", response.body
    assert_equal 1, topic.reload.likes_count

    post likes_path, params: {type: "Topic", id: topic.id}
    assert_equal "1", response.body
    assert_equal 1, topic.reload.likes_count
    sign_out user

    sign_in user2
    post likes_path, params: {type: "Topic", id: topic.id}
    assert_equal "2", response.body
    assert_equal 2, topic.reload.likes_count
    sign_out user2

    sign_in user
    delete like_path(topic.id), params: {type: "Topic"}
    assert_equal "1", response.body
    assert_equal 1, topic.reload.likes_count
    sign_out user

    sign_in user2
    delete like_path(topic.id), params: {type: "Topic"}
    assert_equal "0", response.body
    assert_equal 0, topic.reload.likes_count
  end

  it "require login" do
    post likes_path
    assert_equal 302, response.status

    delete like_path(topic.id), params: {id: 1, type: "a"}
    assert_equal 302, response.status
  end

  it "result -1, -2 when params is wrong" do
    sign_in user
    post likes_path, params: {type: "Ask", id: 1}
    assert_equal "-1", response.body

    delete like_path(1), params: {type: "Ask", id: 1}
    assert_equal "-1", response.body

    post likes_path, params: {type: "Topic", id: -1}
    assert_equal "-2", response.body

    delete like_path(-1), params: {type: "Topic", id: -1}
    assert_equal "-2", response.body
  end
end
