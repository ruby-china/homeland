require 'spec_helper'

describe Favorite do
  let(:topic) { Factory :topic }
  let(:user)  { Factory :user }
  let(:user2)  { Factory :user }

  describe "favorite topic" do
    after do
      Favorite.delete_all
    end
    
    it "can favorite/unfavorite topic" do
      user.favorite(topic)
      user.favorites.count.should == 1
      topic.favorites_count.should == 1
      user2.favorite(topic)
      topic.favorites_count.should == 2
      user2.unfavorite(topic)
      user2.favorites.count.should == 0
      topic.favorites_count.should == 1
    end
  end
end