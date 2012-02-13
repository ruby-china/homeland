require 'spec_helper'

describe Like do
  let(:topic) { Factory :topic }
  let(:user)  { Factory :user }
  let(:user2)  { Factory :user }

  describe "like topic" do
    after do
      Like.delete_all
    end

    it "can like/unlike topic" do
      user.like(topic)
      user.likes.count.should == 1
      user.reload
      user.likes_count.should == 1
      topic.reload
      topic.likes_count.should == 1
      user2.like(topic)
      topic.reload
      topic.likes_count.should == 2
      user2.unlike(topic)
      topic.reload
      user2.likes.count.should == 0
      user2.reload
      user2.likes_count.should == 0
      topic.likes_count.should == 1
    end

    it "can tell whether or not liked by a user" do
      topic.liked_by_user?(user).should be_false
      user.like(topic)
      topic.liked_by_user?(user).should be_true
    end
  end
end
