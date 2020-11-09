# frozen_string_literal: true

require "test_helper"

class MentionTopicTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  attr_accessor :user, :topics

  setup do
    @user = create(:user)
    @topics = create_list(:topic, 3)
  end

  test "mentioned_topic_ids" do
    # should extract mentioned user ids
    topic = Topic.new body: "://#{Setting.domain}/topics/#{topics[0].id} ://#{Setting.domain}/topics/456"
    assert_equal [topics[0].id], topic.extract_mentioned_topic_ids

    reply = Reply.new body: "://#{Setting.domain}/topics/#{topics[0].id}
    ://#{Setting.domain}/topics/#{topics[1].id}
    ://#{Setting.domain}/topics/456"
    assert_includes reply.extract_mentioned_topic_ids, topics[0].id
    assert_includes reply.extract_mentioned_topic_ids, topics[1].id
  end

  test "create_releated_for_mentioned_topics" do
    # topic work
    perform_enqueued_jobs do
      t = create :topic, body: "://#{Setting.domain}/topics/#{topics[0].id} ://#{Setting.domain}/topics/456"
      assert_equal 1, topics[0].replies.where(action: "mention", target: t, user_id: t.user_id).count

      assert_no_changes -> { Reply.count } do
        t.save
      end

      # closed topic
      closed_topic = create :topic, closed_at: Time.now
      t = create :topic, body: "://#{Setting.domain}/topics/#{closed_topic.id}"
      assert_equal 1, closed_topic.replies.where(action: "mention", target: t).count

      # reply work
      r = create :reply, body: "://#{Setting.domain}/topics/#{topics[0].id}
      ://#{Setting.domain}/topics/#{topics[1].id}
      ://#{Setting.domain}/topics/456"

      assert_equal 1, topics[0].replies.where(action: "mention", target: r).count
      assert_equal 1, topics[1].replies.where(action: "mention", target: r).count

      assert_no_changes -> { Reply.count } do
        r.save
      end
    end
  end
end
