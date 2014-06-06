# coding: utf-8
require 'spec_helper'

describe Notification::Mention do
  let(:topic) { Factory.create(:topic) }
  let(:n_topic) { Factory.create(:notification_mention, :mentionable => topic) }
  let(:topic1) { Factory.create(:topic) }
  let(:reply) { Factory.create(:reply, :topic => topic1) }
  let(:n_reply) { Factory.create(:notification_mention, :mentionable => reply) }
  
  describe ".content_path" do
    it "should work" do
      n_topic.content_path.should == "/topics/#{topic.id}"
      n_reply.content_path.should == "/topics/#{topic1.id}"
    end
  end
  
  describe ".notify_hash" do
    it "should work" do
      n_topic.notify_hash.keys.should == [:title,:content,:content_path]
      n_topic.notify_hash[:title].should == "#{n_topic.mentionable.user_login} 提及你："
      n_topic.notify_hash[:content].should == n_topic.mentionable_body[0,30]
      n_topic.notify_hash[:content_path].should == n_topic.content_path
    end
  end
end
