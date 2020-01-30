# frozen_string_literal: true

require "test_helper"

class SectionTest < ActiveSupport::TestCase
  test ".default" do
    assert_kind_of Section, Section.default
    assert_equal false, Section.default.new_record?
  end

  test "should update CacheVersion on save" do
    old = 1.minutes.ago
    CacheVersion.section_node_updated_at = old
    create(:section)
    assert_not_equal old, CacheVersion.section_node_updated_at
  end

  test "should update CacheVersion on destroy" do
    old = 1.minutes.ago
    section = create(:section)
    CacheVersion.section_node_updated_at = old
    section.destroy
    assert_not_equal old, CacheVersion.section_node_updated_at
  end
end
