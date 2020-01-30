# frozen_string_literal: true

require "rails_helper"

describe SearchController, type: :controller do
  describe "/search/users" do
    let(:user) { create(:user) }
    let(:users) { [create(:user), create(:user)] }

    it "should work" do
      sign_in user
      allow(User).to receive(:search).and_return(users)
      get :users
      assert_equal 200, response.status
      assert_equal users.map(&:login).sort, response.parsed_body.collect { |j| j["login"] }.sort
      assert_equal users.map(&:name).sort, response.parsed_body.collect { |j| j["name"] }.sort
      assert_equal users.map(&:large_avatar_url).sort, response.parsed_body.collect { |j| j["avatar_url"] }.sort
    end
  end
end
