require 'rails_helper'

describe Team, type: :model do
  let(:team) { create(:team) }

  it { expect(team.class.name).to eq 'Team' }
  it { expect(team[:type]).to eq 'Team' }
  it { expect(team.user_type).to eq :team }

  describe 'Create' do
    let(:team) { build :team, password: nil, password_confirmation: nil }

    it { expect(team.valid?).to eq true }
  end

  describe '.owner? / .member?' do
    let!(:team_owner) { create(:team_owner, team: team) }
    let!(:team_member) { create(:team_member, team: team) }

    it { expect(team.owner?(team_owner.user)).to eq true }
    it { expect(team.owner?(team_member.user)).to eq false }
    it { expect(team.member?(team_owner.user)).to eq true }
    it { expect(team.member?(team_member.user)).to eq true }
  end

  describe 'has_many' do
    let!(:user) { create(:user) }
    let!(:user1) { create(:user) }
    let!(:team) { create(:team, owner_id: user.id) }
    let!(:team_user) { create(:team_user, team: team, user: user1, role: :member) }

    it 'topics should work' do
      create_list(:topic, 2, user: user)
      create_list(:topic, 1, user: user1)
      expect(team.topics.count).to eq 3
      expect(team.topics.pluck(:id)).to include(*user.topics.pluck(:id))
      expect(team.topics.pluck(:id)).to include(*user1.topics.pluck(:id))
    end

    it 'replies should work' do
      create_list(:reply, 2, user: user)
      create_list(:reply, 1, user: user1)
      expect(team.replies.count).to eq 3
      expect(team.replies.pluck(:id)).to include(*user.replies.pluck(:id))
      expect(team.replies.pluck(:id)).to include(*user1.replies.pluck(:id))
    end

    it 'notes should work' do
      create_list(:note, 2, user: user)
      create_list(:note, 1, user: user1)
      expect(team.notes.count).to eq 3
      expect(team.notes.pluck(:id)).to include(*user.notes.pluck(:id))
      expect(team.notes.pluck(:id)).to include(*user1.notes.pluck(:id))
    end
  end
end
