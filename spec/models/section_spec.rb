# frozen_string_literal: true

require "rails_helper"

describe Section, type: :model do
  describe ".default" do
    it "should work" do
      expect(Section.default).to be_a(Section)
      expect(Section.default.new_record?).to eq false
    end
  end

  describe "CacheVersion update" do
    let(:old) { 1.minutes.ago }
    it "should update on save" do
      CacheVersion.section_node_updated_at = old
      create(:section)
      expect(CacheVersion.section_node_updated_at).not_to eq(old)
    end

    it "should update on destroy" do
      section = create(:section)
      CacheVersion.section_node_updated_at = old
      section.destroy
      expect(CacheVersion.section_node_updated_at).not_to eq(old)
    end
  end
end
