# frozen_string_literal: true

require "test_helper"

class TopicComponentTest < ViewComponent::TestCase
  test "nil" do
    component = TopicComponent.new(topic: nil)
    assert_equal "", render_inline(component).inner_html
  end

  test "normal" do
    topic = create(:topic)
    component = TopicComponent.new(topic: topic)
    doc = render_inline(component)
    assert_equal topic.title, doc.css(".topic .title a").attr("title").value
    assert_equal "/topics/#{topic.id}", doc.css(".topic .title a").attr("href").value
  end

  test "collection render" do
    topics = create_list(:topic, 3)
    component = TopicComponent.with_collection(topics)
    doc = render_inline(component)
    assert_equal 3, doc.css(".topic").length
  end
end
