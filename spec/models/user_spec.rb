require 'spec_helper'

describe User do
  let(:topic) { Factory :topic }
  let(:user)  { Factory :user }
  let(:user2)  { Factory :user }
  let(:reply) { Factory :reply }

  describe '#read_topic?' do
    before do
      Rails.cache.write("user:#{user.id}:topic_read:#{topic.id}", nil)
    end
    
    it 'marks the topic as unread' do
      user.topic_read?(topic).should == false
      user.read_topic(topic)
      user.topic_read?(topic).should == true
      user2.topic_read?(topic).should == false
    end
    
    it "marks the topic as unread when got new reply" do
      topic.replies << reply
      user.topic_read?(topic).should == false
      user.read_topic(topic)
      user.topic_read?(topic).should == true
    end
  end
end
