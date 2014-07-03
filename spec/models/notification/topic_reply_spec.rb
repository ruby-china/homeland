# coding: utf-8
require 'rails_helper'

describe Notification::TopicReply, :type => :model do
  let(:n1) { Factory.create(:notification_topic_reply) }
  describe ".content_path" do
    it "should work" do
      expect(n1.content_path).to eq("/topics/#{n1.reply.topic_id}")
    end
  end
  
  describe ".notify_hash" do
    it "should work" do
      expect(n1.notify_hash.keys).to eq([:title,:content,:content_path])
      expect(n1.notify_hash[:title]).to eq("关注的话题有了新回复:")
      expect(n1.notify_hash[:content]).to eq(n1.reply_body[0,30])
      expect(n1.notify_hash[:content_path]).to eq(n1.content_path)
    end
  end
end
