# frozen_string_literal: true

require "rails_helper"

RSpec.describe Device, type: :model do
  let(:device) { create :device }

  describe ".alive?" do
    context "more that 2 weeks" do
      let(:device) { create :device, last_actived_at: 3.weeks.ago }
      it { expect(device.alive?).to eq false }
    end

    context "last_actived_at nil" do
      let(:device) { create :device, last_actived_at: nil }
      it { expect(device.alive?).to eq true }
    end

    context "last_actived_at less than 14 days" do
      let(:device) { create :device, last_actived_at: 14.days.ago }
      it { expect(device.alive?).to eq true }
    end
  end
end
