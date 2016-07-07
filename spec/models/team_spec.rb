require 'rails_helper'

describe Team, type: :model do
  it { expect(Team.new[:type]).to eq 'Team' }
  it { expect(build(:team)[:type]).to eq 'Team' }

  describe 'Create' do
    let(:team) { build :team, password: nil, password_confirmation: nil }

    it { expect(team.valid?).to eq true }
  end
end
