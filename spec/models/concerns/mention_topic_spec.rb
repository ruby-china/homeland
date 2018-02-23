# frozen_string_literal: true

require "rails_helper"

describe MentionTopic, type: :model do
  let(:user) { create :user }
  let(:topics) { create_list(:topic, 3) }

  describe ".mentioned_topic_ids" do
    it "should extract mentioned user ids" do
      topic = Topic.new body: "://#{Setting.domain}/topics/#{topics[0].id} ://#{Setting.domain}/topics/456"
      expect(topic.extract_mentioned_topic_ids).to eq([topics[0].id])
      expect(topic.mentioned_topic_ids).to eq([topics[0].id])

      reply = Reply.new body: "://#{Setting.domain}/topics/#{topics[0].id}
      ://#{Setting.domain}/topics/#{topics[1].id}
      ://#{Setting.domain}/topics/456"
      expect(reply.extract_mentioned_topic_ids).to include(topics[0].id, topics[1].id)
      expect(reply.mentioned_topic_ids).to include(topics[0].id, topics[1].id)
    end
  end

  describe ".create_releated_for_mentioned_topics" do
    it "should topic work" do
      t = create :topic, body: "://#{Setting.domain}/topics/#{topics[0].id} ://#{Setting.domain}/topics/456"
      expect(topics[0].replies.where(action: "mention", target: t).count).to eq 1

      expect { t.save }.to change(Reply, :count).by(0)
    end

    it "should reply work" do
      r = create :reply, body: "://#{Setting.domain}/topics/#{topics[0].id}
      ://#{Setting.domain}/topics/#{topics[1].id}
      ://#{Setting.domain}/topics/456"

      expect(topics[0].replies.where(action: "mention", target: r).count).to eq 1
      expect(topics[1].replies.where(action: "mention", target: r).count).to eq 1

      expect { r.save }.to change(Reply, :count).by(0)
    end
  end
end
