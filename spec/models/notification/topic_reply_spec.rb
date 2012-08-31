# coding: utf-8
require 'spec_helper'

describe Notification::TopicReply do
  let(:n1) { Factory.create(:notification_topic_reply) }
  describe ".content_path" do
    it "should work" do
      n1.content_path.should == "/topics/#{n1.reply.topic_id}"
    end
  end
  
  describe ".notify_hash" do
    it "should work" do
      n1.notify_hash.keys.should == [:title,:content,:content_path]
      n1.notify_hash[:title].should == "关注的话题有了新回复:"
      n1.notify_hash[:content].should == n1.reply_body[0,30]
      n1.notify_hash[:content_path].should == n1.content_path
    end
  end
end
