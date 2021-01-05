# frozen_string_literal: true

require "test_helper"

class ReplyComponentTest < ViewComponent::TestCase
  test "normal" do
    topic = create(:topic)
    reply = create(:reply, topic: topic)
    component = ReplyComponent.new(reply: reply, topic: topic)
    doc = render_inline(component)
    assert_equal 1, doc.css("#reply-#{reply.id}").length
  end

  test "nil" do
    assert_equal "", render_inline(ReplyComponent.new(reply: nil, topic: create(:topic))).to_html
    assert_equal "", render_inline(ReplyComponent.new(reply: create(:reply), topic: nil)).to_html
  end
end
