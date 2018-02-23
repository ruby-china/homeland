# frozen_string_literal: true

require "rails_helper"

describe User, type: :model do
  describe "ProfileFields" do
    let(:user) { create(:user) }
    describe "#profile_field_prefix" do
      it "should work" do
        expect(User.profile_field_prefix(:weibo)).to eq("https://weibo.com/")
        expect(User.profile_field_prefix(:facebook)).to eq("https://facebook.com/")
        expect(User.profile_field_prefix(:instagram)).to eq("https://instagram.com/")
        expect(User.profile_field_prefix(:dribbble)).to eq("https://dribbble.com/")
        expect(User.profile_field_prefix(:douban)).to eq("https://www.douban.com/people/")
        expect(User.profile_field_prefix(:bb)).to eq(nil)
      end
    end

    describe "InstaceMehtods" do
      it "should work" do
        params = {
          weibo: "weibo1",
          douban: "douban1",
          dribbble: "dribbble1"
        }
        user.update_profile_fields(params)
        expect(user.settings.profile_fields).to eq(params)
        expect(user.profile_fields).to eq(params)
        expect(user.profile_field(:weibo)).to eq "weibo1"
        expect(user.profile_field("weibo")).to eq "weibo1"
        expect(user.profile_field("douban")).to eq "douban1"
        expect(user.profile_field(:ddd)).to eq nil
        expect(user.profile_field(:facebook)).to eq nil
        expect(user.full_profile_field(:weibo)).to eq "https://weibo.com/weibo1"
      end
    end
  end
end
