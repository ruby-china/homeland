# frozen_string_literal: true

require "rails_helper"

describe Section, type: :model do
  describe ".default" do
    it "should work" do
      expect(Section.default).to be_a(Section)
      assert_equal false, Section.default.new_record?
    end
  end

  describe "CacheVersion update" do
    let(:old) { 1.minutes.ago }
    it "should update on save" do
      CacheVersion.section_node_updated_at = old
      create(:section)
      refute_equal old, CacheVersion.section_node_updated_at
    end

    it "should update on destroy" do
      section = create(:section)
      CacheVersion.section_node_updated_at = old
      section.destroy
      refute_equal old, CacheVersion.section_node_updated_at
    end
  end
end
