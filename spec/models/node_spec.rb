# frozen_string_literal: true

require "rails_helper"

describe Node, type: :model do
  describe "Validates" do
    it "should fail saving without specifing a section" do
      node = Node.new
      node.name = "Cersei"
      node.summary = "the Queue"
      node.save == false
    end
  end

  describe "CacheVersion update" do
    let(:old) { 1.minutes.ago }

    it "should update on save" do
      CacheVersion.section_node_updated_at = old
      create(:node)
      refute_equal old, CacheVersion.section_node_updated_at
    end

    it "should update on destroy" do
      node = create(:node)
      CacheVersion.section_node_updated_at = old
      node.destroy!
      refute_equal old, CacheVersion.section_node_updated_at
    end
  end

  describe ".summary_html" do
    let(:node) { create(:node) }
    it "should return html" do
      node.summary = "# foo"
      assert_equal '<h2 id="foo">foo</h2>', node.summary_html
    end

    it "should expire cache on node update" do
      node.summary_html
      node.update!(summary: "# dar")
      assert_equal "# dar", node.summary
      assert_equal '<h2 id="dar">dar</h2>', node.summary_html
    end
  end

  describe ".collapse_summary?" do
    let(:node) { create(:node) }
    it "should work" do
      assert_equal false, node.collapse_summary?
      node.update!(summary: "foo\n\nbar")
      assert_equal false, node.collapse_summary?
      node.update!(summary: "foo\n\nbar\n\ndar")
      assert_equal true, node.collapse_summary?
      node.update!(summary: "foo\n\n- bar\n- dar")
      assert_equal true, node.collapse_summary?
    end
  end

  describe "find_builtin_node" do
    it "should work" do
      node = Node.find_builtin_node(10, "Foo")
      assert_equal false, node.new_record?
      assert_equal 10, node.id
      assert_equal "Foo", node.name
    end

    it "should work when same id exists" do
      exist_node = create(:node)
      node = Node.find_builtin_node(exist_node.id, "Foo")
      assert_equal node, exist_node
    end
  end
end
