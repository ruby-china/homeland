# frozen_string_literal: true

require "rails_helper"

describe "GET /:login", type: :request do
  describe "login with complex cases" do
    it "should work" do
      %w[foo foo1 1234 foo-bar foo_bar foo_ foo.bar].each do |login|
        create(:user, login: login)
        get "/#{login}"
        assert_equal 200, response.status
      end
    end
  end
end
