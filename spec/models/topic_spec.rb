require 'spec_helper'

describe Topic do
  let(:topic) { Factory :topic, :user => user }
  let(:user)  { Factory :user }

  describe '#user_readed?' do
    let(:user_read)    { Factory :user }
    let(:user_unread)  { Factory :user }
    let(:user_replier) { Factory :user }
    let(:topic2)       { Factory :topic, :user => user }

    before do
      topic.update_attribute :last_reply_user_id, user_replier.id
      Rails.cache.write("Topic:user_read:#{topic.id}", [user.id, user_read.id])
      Rails.cache.write("Topic:user_read:#{topic2.id}", nil)
    end

    it 'marks the topic as unread' do
      topic.user_readed?(user_unread.id).should == 1
      topic2.user_readed?(user_unread.id).should == 1
    end

    it 'marks the topic as read' do
      topic.user_readed?(user.id).should == 0
      topic.user_readed?(user_read.id).should == 0
    end

    it 'marks the topic as replied by the user' do
      topic.user_readed?(user_replier.id).should == 2
      topic2.user_readed?(user.id).should == 2
    end
  end
end