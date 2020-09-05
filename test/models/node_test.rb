# frozen_string_literal: true

require "test_helper"

class NodeTest < ActiveSupport::TestCase
  attr_accessor :node
  setup do
    @node = create(:node)
  end

  test "should fail saving without specifing a section" do
    node = Node.new
    node.name = "Cersei"
    node.summary = "the Queue"
    node.save == false
  end

  test "should update CacheVersion on save" do
    old_time = 1.minutes.ago
    CacheVersion.section_node_updated_at = old_time
    create(:node)
    refute_equal old_time, CacheVersion.section_node_updated_at
  end

  test "should update on destroy" do
    old_time = 5.minutes.ago
    CacheVersion.section_node_updated_at = old_time
    node.destroy!
    refute_equal old_time, CacheVersion.section_node_updated_at
  end

  test ".summary_html should return html" do
    node.summary = "# foo"
    assert_equal '<h2 id="foo">foo</h2>', node.summary_html
  end

  test "should expire cache on node update" do
    node.summary_html
    node.update!(summary: "# dar")
    assert_equal "# dar", node.summary
    assert_equal '<h2 id="dar">dar</h2>', node.summary_html
  end

  test ".collapse_summary?" do
    assert_equal false, node.collapse_summary?
    node.update!(summary: "foo\n\nbar")
    assert_equal false, node.collapse_summary?
    node.update!(summary: "foo\n\nbar\n\ndar")
    assert_equal true, node.collapse_summary?
    node.update!(summary: "foo\n\n- bar\n- dar")
    assert_equal true, node.collapse_summary?
  end

  test "find_builtin_node" do
    node = Node.find_builtin_node(10, "Foo")
    assert_equal false, node.new_record?
    assert_equal 10, node.id
    assert_equal "Foo", node.name

    exist_node = create(:node)
    node = Node.find_builtin_node(exist_node.id, "Foo")
    assert_equal node, exist_node
  end

  test "is nickname node" do
    node1 = create(:node, name: "你好")
    assert_equal false, node1.nickname_node?

    node2 = create(:node, name: "匿名")
    assert_equal true, node2.nickname_node?

    node3 = create(:node, name: "匿名包裹")
    assert_equal true, node3.nickname_node?
  end
end
