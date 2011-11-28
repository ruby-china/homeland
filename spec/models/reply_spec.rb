require 'spec_helper'

describe Reply do
  describe "extract mention" do
    it "should extract mentioned user ids" do
      user = Factory :user
      reply = Factory :reply, :body => "@#{user.login}"
      reply.mentioned_user_ids.should == [user.id]
      reply.mentioned_user_logins.should == [user.login]
    end

    it "limit 5 mentioned user" do
      logins = ""
      6.times { logins << " @#{Factory(:user).login}" }
      reply = Factory :reply, :body => logins
      reply.mentioned_user_ids.count.should == 5
    end

    it "except self user" do
      user = Factory :user
      reply = Factory :reply, :body => "@#{user.login}", :user => user
      reply.mentioned_user_ids.count.should == 0
    end

    it "should ge mentioned user logins" do
      user1 = Factory :user
      user2 = Factory :user
      reply = Factory :reply, :mentioned_user_ids => [user1.id, user2.id]
      reply.mentioned_user_logins.should =~ [user1.login, user2.login]
    end

    it "should send mention notification" do
      user = Factory :user
      lambda do
        Factory :reply, :mentioned_user_ids => [user.id]
      end.should change(user.notifications.unread, :count)
    end
  end
end
