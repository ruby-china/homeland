# coding: utf-8
require 'rails_helper'

describe Notification::Mention, :type => :model do
  let(:topic) { Factory.create(:topic) }
  let(:n_topic) { Factory.create(:notification_mention, :mentionable => topic) }
  let(:topic1) { Factory.create(:topic) }
  let(:reply) { Factory.create(:reply, :topic => topic1) }
  let(:n_reply) { Factory.create(:notification_mention, :mentionable => reply) }
  
  describe ".content_path" do
    it "should work" do
      expect(n_topic.content_path).to eq("/topics/#{topic.id}")
      expect(n_reply.content_path).to eq("/topics/#{topic1.id}")
    end
  end
  
  describe ".notify_hash" do
    it "should work" do
      expect(n_topic.notify_hash.keys).to eq([:title,:content,:content_path])
      expect(n_topic.notify_hash[:title]).to eq("#{n_topic.mentionable.user_login} 提及你：")
      expect(n_topic.notify_hash[:content]).to eq(n_topic.mentionable_body[0,30])
      expect(n_topic.notify_hash[:content_path]).to eq(n_topic.content_path)
    end
  end
end
