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

      lambda do
        Factory(:reply, :mentioned_user_ids => [user.id]).destroy
      end.should_not change(user.notifications.unread, :count)
    end

    it "should send topic reply notification to topic author" do
      user = Factory :user
      topic = Factory :topic, :user => user
      lambda do
        Factory :reply, :topic => topic
      end.should change(user.notifications.unread, :count)

      lambda do
        Factory(:reply, :topic => topic).destroy
      end.should_not change(user.notifications.unread, :count)

      lambda do
        Factory :reply, :topic => topic, :user => user
      end.should_not change(user.notifications.unread, :count)

      # Don't duplicate notifiation with mention
      lambda do
        Factory :reply, :topic => topic, :mentioned_user_ids => [user.id]
      end.should_not change(user.notifications.unread.where(:_type => 'Notification::TopicReply'), :count)
    end

    it "should update Topic updated_at on Reply updated" do
      topic = Factory :topic, :updated_at => 1.days.ago
      old_updated_at = topic.updated_at
      reply = Factory :reply, :topic => topic
      topic.updated_at.should_not == old_updated_at
      reply.body = "foobar"
      reply.save
      topic.updated_at.should_not == old_updated_at
    end
  end

  describe "format body" do
    it "should covert body with Markdown on create" do
      r = Factory(:reply, :body => "*foo*")
      r.body_html.should == "<p><em>foo</em></p>"
    end

    it "should covert body on save" do
      r = Factory(:reply, :body => "*foo*")
      old_html = r.body_html
      r.body = "*bar*"
      r.save
      r.body_html.should_not == old_html
    end

    it "should not store body_html when it not changed" do
      r = Factory(:reply, :body => "*foo*")
      r.body = "*fooaa*"
      r.stub!(:body_changed?).and_return(false)
      old_html = r.body_html
      r.save
      r.body_html.should == old_html
    end
  end
end
