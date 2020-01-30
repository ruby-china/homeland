# frozen_string_literal: true

require "rails_helper"

describe MentionTopic, type: :model do
  let(:user) { create :user }
  let(:topics) { create_list(:topic, 3) }

  describe ".mentioned_topic_ids" do
    it "should extract mentioned user ids" do
      topic = Topic.new body: "://#{Setting.domain}/topics/#{topics[0].id} ://#{Setting.domain}/topics/456"
      assert_equal [topics[0].id], topic.extract_mentioned_topic_ids

      reply = Reply.new body: "://#{Setting.domain}/topics/#{topics[0].id}
      ://#{Setting.domain}/topics/#{topics[1].id}
      ://#{Setting.domain}/topics/456"
      assert_includes reply.extract_mentioned_topic_ids, topics[0].id
      assert_includes reply.extract_mentioned_topic_ids, topics[1].id
    end
  end

  describe ".create_releated_for_mentioned_topics" do
    it "should topic work" do
      t = create :topic, body: "://#{Setting.domain}/topics/#{topics[0].id} ://#{Setting.domain}/topics/456"
      assert_equal 1, topics[0].replies.where(action: "mention", target: t, user_id: t.user_id).count

      expect { t.save }.to change(Reply, :count).by(0)
    end

    it "should close topic work" do
      closed_topic = create :topic, closed_at: Time.now
      t = create :topic, body: "://#{Setting.domain}/topics/#{closed_topic.id}"
      assert_equal 1, closed_topic.replies.where(action: "mention", target: t).count
    end

    it "should reply work" do
      r = create :reply, body: "://#{Setting.domain}/topics/#{topics[0].id}
      ://#{Setting.domain}/topics/#{topics[1].id}
      ://#{Setting.domain}/topics/456"

      assert_equal 1, topics[0].replies.where(action: "mention", target: r).count
      assert_equal 1, topics[1].replies.where(action: "mention", target: r).count

      expect { r.save }.to change(Reply, :count).by(0)
    end
  end
end
