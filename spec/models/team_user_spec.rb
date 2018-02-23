# frozen_string_literal: true

require "rails_helper"

describe TeamUser, type: :model do
  let(:user) { create(:user) }

  describe "Create via login" do
    it "should work" do
      team_user = build(:team_user, login: user.login)
      expect(team_user.save).to eq true
      expect(team_user.user_id).to eq user.id
    end

    it "should add error when user not exists" do
      team_user = build(:team_user, login: "lasdjgalksdjgsad")
      expect(team_user.valid?).to eq false
    end
  end
end
