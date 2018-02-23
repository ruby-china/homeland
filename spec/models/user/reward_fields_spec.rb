# frozen_string_literal: true

require "rails_helper"

describe User, type: :model do
  describe "RewardFields" do
    let(:user) { create(:user) }

    it "should work" do
      params = {
        alipay: "alipay111",
        wechat: "wechat111"
      }
      expect(user.reward_enabled?).to eq false
      user.update_reward_fields(params)
      expect(user.reward_enabled?).to eq true
      expect(user.settings.reward_fields).to eq(params)
      expect(user.reward_fields).to eq(params)
      expect(user.reward_field(:wechat)).to eq "wechat111"
      expect(user.reward_field("wechat")).to eq "wechat111"
      expect(user.reward_field("alipay")).to eq "alipay111"
      expect(user.reward_field(:ddd)).to eq nil
      expect(user.reward_field(:facebook)).to eq nil
      expect(User.reward_field_label(:wechat)).to eq "微信"
      expect(User.reward_field_label(:alipay)).to eq "支付宝"
    end
  end
end
