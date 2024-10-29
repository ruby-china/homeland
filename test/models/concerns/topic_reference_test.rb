require "test_helper"

class TopicReferenceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "topic" do
    perform_enqueued_jobs do
      t1 = create(:topic)
      t1_updated_at = t1.updated_at
      t2 = create(:topic)
      t2_udpated_at = t2.updated_at
      t3 = create(:topic)

      sleep 0.01
      t1.update(body: "hello /topics/#{t2.id} and /topics/#{t3.id} /topics/#{t2.id} /topics/#{t1.id} /topics/0123456789")
      t1.reload
      assert_equal 2, t1.reference_topic_ids.count
      assert_equal [t2.id, t3.id], t1.reference_topic_ids.sort
      assert t1_updated_at != t1.updated_at
      t2.reload
      assert t2_udpated_at != t2.updated_at

      # When update body, should keep the old reference
      t1.update(body: "hello /topics/#{t2.id}")
      t1.reload
      assert_equal [t2.id, t3.id], t1.reference_topic_ids.sort
    end
  end

  test "reply" do
    perform_enqueued_jobs do
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
end
