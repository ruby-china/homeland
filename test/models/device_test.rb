# frozen_string_literal: true

require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  test ".alive?" do
    device = build :device, last_actived_at: 3.weeks.ago
    assert_equal false, device.alive?

    # last_actived_at nil
    device = build :device, last_actived_at: nil
    assert_equal true, device.alive?

    # last_actived_at less than 14 days
    device = create :device, last_actived_at: 14.days.ago
    assert_equal true, device.alive?
  end
end
