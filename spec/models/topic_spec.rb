require 'spec_helper'

describe Topic do
  it "should set replied_at" do
    Factory(:topic).replied_at.should_not be_nil
  end

  it "should get node name" do
    node = Factory :node
    Factory(:topic, :node => node).node_name.should == node.name
  end

  it "should push and pull follower" do
    topic = Factory :topic
    user  = Factory :user
    topic.push_follower user.id
    topic.follower_ids.include?(user.id).should be_true
    topic.pull_follower user.id
    topic.follower_ids.include?(user.id).should_not be_true
  end

  it "should update after reply" do
    topic = Factory :topic
    reply = Factory :reply, :topic => topic
    topic.replied_at.should == reply.created_at
    topic.last_reply_id.should == reply.id
    topic.last_reply_user_id.should == reply.user_id
    topic.follower_ids.include?(reply.user_id).should be_true
  end
end
