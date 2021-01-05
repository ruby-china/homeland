# frozen_string_literal: true

require "test_helper"

class User::SoftDeleteTest < ActiveSupport::TestCase
  test "soft_delete" do
    user = create(:user)

    user.soft_delete
    user.reload
    assert_equal "deleted", user.state
    assert_equal true, user.deleted?
  end
end
