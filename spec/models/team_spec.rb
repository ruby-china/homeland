require 'rails_helper'

describe Team, type: :model do
  let(:team) { create(:team) }

  it { expect(team.class.name).to eq 'Team' }
  it { expect(team[:type]).to eq 'Team' }

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
end
