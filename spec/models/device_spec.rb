# frozen_string_literal: true

require "rails_helper"

RSpec.describe Device, type: :model do
  let(:device) { create :device }

  describe ".alive?" do
    context "more that 2 weeks" do
      let(:device) { create :device, last_actived_at: 3.weeks.ago }
      it { assert_equal false, device.alive?}
    end

    context "last_actived_at nil" do
      let(:device) { create :device, last_actived_at: nil }
      it { assert_equal true, device.alive?}
    end

    context "last_actived_at less than 14 days" do
      let(:device) { create :device, last_actived_at: 14.days.ago }
      it { assert_equal true, device.alive?}
    end
  end
end
