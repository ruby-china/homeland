require 'spec_helper'

class TestDocument
  include Mongoid::Document
  include Mongoid::Mentionable

  belongs_to :user
  field :body
end

describe Mongoid::Mentionable do
  it "should extract mentioned user ids" do
    user = Factory :user
    doc = TestDocument.create :body => "@#{user.login}", :user => Factory(:user)
    doc.mentioned_user_ids.should == [user.id]
    doc.mentioned_user_logins.should == [user.login]
  end

  it "limit 5 mentioned user" do
    logins = ""
    6.times { logins << " @#{Factory(:user).login}" }
    doc = TestDocument.create :body => logins, :user => Factory(:user)
    doc.mentioned_user_ids.count.should == 5
  end

  it "except self user" do
    user = Factory :user
    doc = TestDocument.create :body => "@#{user.login}", :user => user
    doc.mentioned_user_ids.count.should == 0
  end

  it "should get mentioned user logins" do
    user1 = Factory :user
    user2 = Factory :user
    doc = TestDocument.create :body => "@#{user1.login} @#{user2.login}", :user => Factory(:user)
    doc.mentioned_user_logins.should =~ [user1.login, user2.login]
  end

  it "should send mention notification" do
    user = Factory :user
    lambda do
      TestDocument.create :body => "@#{user.login}", :user => Factory(:user)
    end.should change(user.notifications.unread, :count)

    lambda do
      TestDocument.create(:body => "@#{user.login}", :user => user)
    end.should_not change(user.notifications.unread, :count)

    lambda do
      TestDocument.create(:body => "@#{user.login}", :user => Factory(:user)).destroy
    end.should_not change(user.notifications.unread, :count)
  end
end
