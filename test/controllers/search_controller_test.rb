# frozen_string_literal: true

require "spec_helper"

describe SearchController do
  describe "GET /search" do
    it "should work" do
      get search_path
      assert_equal 200, response.status
    end
  end

  describe "GET /search/users" do
    let(:user) { create(:user) }
    let(:users) { [create(:user), create(:user)] }

    it "should work" do
      sign_in user
      User.stubs(:search).returns(users)
      get search_users_path
      assert_equal 200, response.status
      assert_equal users.map(&:login).sort, response.parsed_body.collect { |j| j["login"] }.sort
      assert_equal users.map(&:name).sort, response.parsed_body.collect { |j| j["name"] }.sort
      assert_equal users.map(&:large_avatar_url).sort, response.parsed_body.collect { |j| j["avatar_url"] }.sort
    end
  end
end
