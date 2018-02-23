# frozen_string_literal: true

require "rails_helper"

describe Team, type: :model do
  let(:team) { create(:team) }

  it { expect(team.class.name).to eq "Team" }
  it { expect(team[:type]).to eq "Team" }
  it { expect(team.user_type).to eq :team }

  describe "Create" do
    let(:team) { build :team, password: nil, password_confirmation: nil }

    it { expect(team.valid?).to eq true }
  end

  describe ".owner? / .member?" do
    let!(:team_owner) { create(:team_owner, team: team) }
    let!(:team_member) { create(:team_member, team: team) }

    it { expect(team.owner?(team_owner.user)).to eq true }
    it { expect(team.owner?(team_member.user)).to eq false }
    it { expect(team.member?(team_owner.user)).to eq true }
    it { expect(team.member?(team_member.user)).to eq true }

    it "should touch team when member changed" do
      old_updated_at = team.updated_at
      team.team_users.last.destroy!
      team.reload
      sleep 0.01
      expect(team.updated_at.to_f).not_to eq old_updated_at.to_f

      old_updated_at = team.updated_at
      team.team_users.create!(user: create(:user))
      sleep 0.01
      team.reload
      expect(team.updated_at.to_f).not_to eq old_updated_at.to_f
    end
  end

  describe "has_many" do
    let!(:user) { create(:user) }
    let!(:user1) { create(:user) }
    let!(:team) { create(:team, owner_id: user.id) }
    let!(:team_user) { create(:team_user, team: team, user: user1, role: :member) }

    it "topics should work" do
      create_list(:topic, 2, user: user, team_id: team.id)
      create_list(:topic, 1, user: user1, team_id: team.id)
      expect(team.topics.count).to eq 3
      expect(team.topics.pluck(:id)).to include(*user.topics.pluck(:id))
      expect(team.topics.pluck(:id)).to include(*user1.topics.pluck(:id))
    end
  end
end
