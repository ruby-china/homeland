# frozen_string_literal: true

require "test_helper"

class UsersTest < ActionDispatch::IntegrationTest
  test "login with complex cases" do
    %w[foo foo1 1234 foo-bar foo_bar foo_ foo.bar].each do |login|
      create(:user, login: login)
      get "/#{login}"
      assert_equal 200, response.status
    end
  end
end
