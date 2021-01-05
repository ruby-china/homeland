# frozen_string_literal: true

require "test_helper"

class ReplyToComponentTest < ViewComponent::TestCase
  setup do
    @topic = create(:topic)
    @reply_to = create(:reply, topic: @topic)
    @reply = create(:reply, reply_to: @reply_to, topic: @topic)
  end

  test "normal" do
    component = ReplyToComponent.new(reply: @reply, topic: @topic)
    doc = render_inline(component)
    assert_equal 0, doc.css(".markdown").length
  end

  test "show body" do
    component = ReplyToComponent.new(reply: @reply, topic: @topic, show_body: true)
    doc = render_inline(component)
    assert_equal 1, doc.css(".markdown").length
  end

  test "nil" do
    assert_equal "", render_inline(ReplyToComponent.new(reply: nil, topic: @topic)).to_html
  end
end
