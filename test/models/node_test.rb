# frozen_string_literal: true

require "test_helper"

class NodeTest < ActiveSupport::TestCase
  attr_accessor :node
  setup do
    @node = create(:node)
  end

  test "should valid with only name present" do
    node = Node.new
    node.name = "Cersei"
    assert_equal true, node.valid?
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
end
