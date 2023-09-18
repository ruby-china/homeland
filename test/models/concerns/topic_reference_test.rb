# frozen_string_literal: true

require "spec_helper"

class TopicReferenceTest < ActiveSupport::TestCase
  test "topic" do
    t1 = create(:topic)
    t2 = create(:topic)
    t3 = create(:topic)

    t1.update(body: "hello /topics/#{t2.id} and /topics/#{t3.id} /topics/#{t2.id} /topics/#{t1.id} /topics/111222222222222")
    t1.reload
    assert_equal 2, t1.reference_topic_ids.count
    assert_equal [t2.id, t3.id], t1.reference_topic_ids.sort

    # When update body, should keep the old reference
    t1.update(body: "hello /topics/#{t2.id}")
    t1.reload
    assert_equal [t2.id, t3.id], t1.reference_topic_ids.sort
  end

  test "reply" do
    t = create(:topic)
    t2 = create(:topic)
    r1 = create(:reply)
    r2 = create(:reply, body: "hello /topics/#{t.id} /topics/#{t2.id}", topic: t2)

    r2.topic.reload
    assert_equal 1, r2.topic.reference_topic_ids.count
    assert_equal [t.id], r2.topic.reference_topic_ids

    r1.update(body: "hello /topics/#{t.id}")
    r1.reload
    assert_equal 1, r1.topic.reference_topic_ids.count

    t.reload
    assert_equal 2, t.reference_by_topics.count
    assert_equal [t2.id, r1.topic_id].sort, t.reference_by_topics.pluck(:id).sort
  end
end
