# frozen_string_literal: true

require "test_helper"

class TeamUserTest < ActiveSupport::TestCase
  test "Create via login" do
    user = create(:user)

    team_user = build(:team_user, login: user.login)
    assert_equal true, team_user.save
    assert_equal user.id, team_user.user_id

    # should add error when user not exists
    team_user = build(:team_user, login: "lasdjgalksdjgsad")
    assert_equal false, team_user.valid?
  end
end
