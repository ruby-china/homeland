# frozen_string_literal: true

require "rails_helper"

describe TeamUser, type: :model do
  let(:user) { create(:user) }

  describe "Create via login" do
    it "should work" do
      team_user = build(:team_user, login: user.login)
      assert_equal true, team_user.save
      assert_equal user.id, team_user.user_id
    end

    it "should add error when user not exists" do
      team_user = build(:team_user, login: "lasdjgalksdjgsad")
      assert_equal false, team_user.valid?
    end
  end
end
